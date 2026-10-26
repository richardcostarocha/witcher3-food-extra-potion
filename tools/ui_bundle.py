from pathlib import Path
import struct,zlib
from binary_index import Index,fnv1a,verify_bundle_and_index
BASE=Path(__file__).resolve().parents[1]/'mods/modSlotComida'

def unpack_bundle(content):
    b = (content / 'blob0.bundle').read_bytes()
    idx = Index((content / 'metadata.store').read_bytes())
    result = {}
    for i in range(struct.unpack_from('<I', b, 16)[0] // 304):
        at = 32 + i * 304
        name = b[at:at + 256].split(b'\x00')[0].decode('ascii')
        v = struct.unpack_from('<12I', b, at + 256)
        assert v[9] == 1
        raw = zlib.decompress(b[v[4]:v[4] + v[7]])
        assert len(raw) == v[6] and zlib.crc32(raw) == v[8]
        flags = next((row[2] for row in idx.hashes if row[0] == fnv1a(name)))
        result[name] = (raw, flags)
    return result

def verify_cr2w(b):
    assert b[:8] == b'CR2W\xa4\x00\x00\x00'
    assert struct.unpack_from('<II', b, 24) == (len(b), len(b))
    header = bytearray(b[:160])
    struct.pack_into('<I', header, 32, 3735928559)
    assert zlib.crc32(header) == struct.unpack_from('<I', b, 32)[0]
    for table, stride in enumerate((1, 8, 8, 16, 24)):
        at, count, crc = struct.unpack_from('<III', b, 40 + 12 * table)
        assert zlib.crc32(b[at:at + count * stride]) == crc
    exports, count = struct.unpack_from('<II', b, 88)
    for i in range(count):
        size, at = struct.unpack_from('<II', b, exports + i * 24 + 8)
        crc = struct.unpack_from('<I', b, exports + i * 24 + 20)[0]
        assert zlib.crc32(b[at:at + size]) == crc

def pack(resources, content):
    template = Index((BASE / 'content/metadata.store').read_bytes())
    idx = Index((BASE / 'content/metadata.store').read_bytes())
    idx.strings = bytearray(b'\x00blob0.bundle\x00')
    idx.infos, idx.entries = ([template.infos[0]], [template.entries[0]])
    idx.bundles, idx.buffers = ([template.bundles[0]], [])
    idx.dirs, idx.files, idx.hashes = ([(0, 0)], [], [])
    directories = {(): 0}

    def add_string(s):
        offset = len(idx.strings)
        idx.strings.extend(s.encode('ascii') + b'\x00')
        return offset

    def directory(parts):
        if parts not in directories:
            parent = directory(parts[:-1])
            directories[parts] = len(idx.dirs)
            idx.dirs.append((add_string(parts[-1]), parent))
        return directories[parts]
    header_size = 32 + len(resources) * 304
    old = (BASE / 'content/blob0.bundle').read_bytes()
    bundle = bytearray(old[:32]) + bytearray(len(resources) * 304)
    struct.pack_into('<I', bundle, 16, len(resources) * 304)
    struct.pack_into('<I', bundle, 22, header_size)
    expected = {}
    for file_id, (name, (raw, flags)) in enumerate(resources.items(), 1):
        packed = zlib.compress(raw, 9)
        bundle.extend(bytes(-len(bundle) % 16))
        offset = len(bundle)
        bundle.extend(packed)
        at = 32 + (file_id - 1) * 304
        bundle[at:at + 256] = name.encode('ascii').ljust(256, b'\x00')
        struct.pack_into('<12I', bundle, at + 256, 0, 0, 0, 0, offset, 0, len(raw), len(packed), zlib.crc32(raw), 1, 0, 0)
        path_offset = add_string(name)
        idx.infos.append((path_offset, 0, len(packed), len(raw), file_id, 0, 0, 1))
        idx.entries.append((offset, len(packed), 0, file_id, 1))
        dir_id = directory(tuple(name.split('\\')[:-1]))
        idx.files.append((file_id, dir_id, path_offset + name.rindex('\\') + 1))
        idx.hashes.append((fnv1a(name), file_id, flags))
        expected[name] = raw
    bundle.extend(bytes(-len(bundle) % 16))
    struct.pack_into('<I', bundle, 8, len(bundle))
    idx.bundles.append((len(bundle) - header_size, header_size, 1, 1, len(resources)))
    idx.hashes.sort(key=lambda row: row[0])
    idx.header = idx.header[:8] + struct.pack('<II', max((row[2] for row in idx.infos)), max((row[3] for row in idx.infos)))
    meta = idx.write()
    verify_bundle_and_index(bytes(bundle), meta, expected)
    (content / 'blob0.bundle').write_bytes(bundle)
    (content / 'metadata.store').write_bytes(meta)
