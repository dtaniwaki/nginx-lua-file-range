# nginx-lua-file-range

Lua script to serve static files with range specified by queries.

## Usage

Write your nginx config file like below.

```
location / {
    root /media/;

    set $file_range_chunk_size 10000;

    lua_check_client_abort on;
    lua_http10_buffering off;

    content_by_lua_file /etc/nginx/file-range.lua;
}
```

Then, your static file serving can be extended with the following queries.

### `offset`

Serve a file with offset.

e.g. `http://localhost/samplefile.txt?offset=2` to skip the first 2 bytes.

### `limit`

Serve a file with size limit.

e.g. `http://localhost/samplefile.txt?limit=5` to read only 5 bytes of the file.

## Configuration

Here're the configurations for file-range.

### `file_range_chunk_size`

Chunk size to read a file and write to the response.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2018 Daisuke Taniwaki. See [LICENSE](LICENSE) for details.

