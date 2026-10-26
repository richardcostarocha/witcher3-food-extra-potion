import struct,zlib

def vlq(value, negative_zero=False):
    result = bytearray([value & 63])
    value >>= 6
    if value:
        result[0] |= 64
    while value:
        byte = value & 127
        value >>= 7
        result.append(byte | (128 if value else 0))
    if negative_zero:
        result[0] |= 128
    return result

def fnv1a(path):
    result = 14695981039346656037
    for byte in path.encode('ascii'):
        result = (result ^ byte) * 1099511628211 & 18446744073709551615
    return result

class Index:

    def __init__(self, data):
        self.header = data[:16]
        self.data = data
        self.pos = 16
        length, _ = self.read_vlq()
        self.strings = bytearray(data[self.pos:self.pos + length])
        self.pos += length
        self.infos = self.read_array('<8I')
        self.entries = self.read_array('<QIIII')
        self.bundles = self.read_array('<QIIII')
        count, self.buffer_negative_zero = self.read_vlq()
        self.buffers = list(struct.unpack_from(f'<{count}I', data, self.pos))
        self.pos += count * 4
        self.dirs = self.read_array('<II')
        self.files = self.read_array('<III')
        self.hashes = self.read_array('<QII')
        assert self.pos == len(data), (self.pos, len(data))

    def read_vlq(self):
        byte = self.data[self.pos]
        self.pos += 1
        negative = bool(byte & 128)
        value, shift, more = (byte & 63, 6, byte & 64)
        while more:
            byte = self.data[self.pos]
            self.pos += 1
            value |= (byte & 127) << shift
            more = byte & 128
            shift += 7
        return (value, negative)

    def read_array(self, fmt):
        count, negative = self.read_vlq()
        assert not negative
        size = struct.calcsize(fmt)
        result = [struct.unpack_from(fmt, self.data, self.pos + i * size) for i in range(count)]
        self.pos += size * count
        return result

    def string(self, offset):
        return bytes(self.strings[offset:]).split(b'\x00')[0].decode('ascii')

    def write(self):
        result = bytearray(self.header)
        result += vlq(len(self.strings)) + self.strings
        for fmt, values in (('<8I', self.infos), ('<QIIII', self.entries), ('<QIIII', self.bundles)):
            result += vlq(len(values))
            for value in values:
                result += struct.pack(fmt, *value)
        result += vlq(len(self.buffers), self.buffer_negative_zero)
        result += struct.pack(f'<{len(self.buffers)}I', *self.buffers)
        for fmt, values in (('<II', self.dirs), ('<III', self.files), ('<QII', self.hashes)):
            result += vlq(len(values))
            for value in values:
                result += struct.pack(fmt, *value)
        return bytes(result)

def verify_bundle_and_index(bundle, meta, expected):
    index = Index(meta)
    assert index.write() == meta
    table_size = struct.unpack_from('<I', bundle, 16)[0]
    count = table_size // 304
    assert count == len(expected)
    assert struct.unpack_from('<I', bundle, 8)[0] == len(bundle)
    assert len(index.infos) == len(index.entries) == count + 1
    assert len(index.files) == len(index.hashes) == count
    assert index.bundles[1][4] == count
    assert struct.unpack('<II', index.header[8:]) == (max((row[2] for row in index.infos)), max((row[3] for row in index.infos)))
    for i in range(count):
        record = 32 + i * 304
        path = bundle[record:record + 256].split(b'\x00')[0].decode('ascii')
        values = struct.unpack_from('<12I', bundle, record + 256)
        assert values[9] == 1
        packed = bundle[values[4]:values[4] + values[7]]
        raw = zlib.decompress(packed)
        assert raw == expected[path]
        assert len(raw) == values[6] and zlib.crc32(raw) == values[8]
        info = index.infos[i + 1]
        assert index.string(info[0]) == path
        assert info[2:5] == (len(packed), len(raw), i + 1)
        assert info[7] == 1
        assert index.entries[i + 1] == (values[4], len(packed), 0, i + 1, 1)
        row = next((x for x in index.files if x[0] == i + 1))
        pieces = [index.string(row[2])]
        dir_id = row[1]
        while dir_id:
            name, dir_id = index.dirs[dir_id]
            pieces.insert(0, index.string(name))
        assert '\\'.join(pieces) == path
        assert any((x[0] == fnv1a(path) and x[1] == i + 1 for x in index.hashes))
    assert index.bundles[1][0] == len(bundle) - index.bundles[1][1]
