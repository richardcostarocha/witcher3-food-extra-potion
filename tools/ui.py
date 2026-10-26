from pathlib import Path
import argparse,hashlib,json
from ui_bundle import unpack_bundle,pack,verify_cr2w
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'mods/modSlotComida/content'
def safe_parts(name):
    parts=name.split('\\')
    assert parts and not any(p in ('','.','..') or ':' in p or '/' in p for p in parts),'Invalid resource path'
    return parts
if __name__=='__main__':
    parser=argparse.ArgumentParser(description='Inspect/unpack/repack the existing UI bundle; never installs or uploads it.')
    parser.add_argument('command',choices=['inspect','unpack','repack']);parser.add_argument('--out');parser.add_argument('--resources');args=parser.parse_args()
    if args.command=='inspect':
        for name,(raw,flags) in unpack_bundle(SOURCE).items():print(name,len(raw),hashlib.sha256(raw).hexdigest())
    elif args.command=='unpack':
        out=Path(args.out).resolve() if args.out else ROOT/'dist/ui-export'
        assert not out.exists(),'Choose a new output directory'
        out.mkdir(parents=True);index={}
        for name,(raw,flags) in unpack_bundle(SOURCE).items():
            dest=out.joinpath(*safe_parts(name));dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(raw);index[name]=flags
        (out/'resources.json').write_text(json.dumps(index,indent=2)+'\n',encoding='utf-8',newline='\n')
        print('Unpacked:',out)
    else:
        assert args.resources,'Pass --resources with an unpacked resource directory'
        source=Path(args.resources).resolve();index=json.loads((source/'resources.json').read_text('utf-8'))
        resources={}
        for name,flags in index.items():
            raw=source.joinpath(*safe_parts(name)).read_bytes()
            if name.endswith(('.redswf','.menu')):verify_cr2w(raw)
            resources[name]=(raw,flags)
        out=Path(args.out).resolve() if args.out else ROOT/'dist/ui-repacked'
        assert not out.exists(),'Choose a new output directory'
        out.mkdir(parents=True);pack(resources,out)
        assert unpack_bundle(out)==resources
        print('Resource bundle and index repacked and verified:',out)
