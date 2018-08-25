-- variables
ngx.log(ngx.INFO, 'request_filename: ' .. tostring(ngx.var.request_filename))
local path = ngx.var.request_filename

ngx.log(ngx.INFO, 'file_range_chunk_size: ' .. tostring(ngx.var.file_range_chunk_size))
local chunk_size = 1000
if ngx.var.file_range_chunk_size ~= nil then
  chunk_size = tonumber(ngx.var.file_range_chunk_size)
end

-- variables by arg
ngx.log(ngx.INFO, 'arg_offset: ' .. tostring(ngx.var.arg_offset))
local offset = 0
if ngx.var.arg_offset ~= nil then
  offset = tonumber(ngx.var.arg_offset)
end
if offset < 0 then
  ngx.log(ngx.INFO, 'offset is invalid: ' .. tostring(offset))
  ngx.exit(ngx.HTTP_BAD_REQUEST)
end

ngx.log(ngx.INFO, 'arg_limit: ' .. tostring(ngx.var.arg_limit))
local limit = nil
if ngx.var.arg_limit ~= nil then
  limit = tonumber(ngx.var.arg_limit)
end
if limit ~= nil and limit < 0 then
  ngx.log(ngx.INFO, 'limit is invalid: ' .. tostring(limit))
  ngx.exit(ngx.HTTP_BAD_REQUEST)
end

ngx.log(ngx.INFO, 'try to read ' .. tostring(limit or 'all') .. ' bytes of file ' .. path .. ' from ' .. tostring(offset) .. ' by chunk size of ' .. tostring(chunk_size))

local f, err = io.open(path, 'rb')
if f == nil then
  ngx.log(ngx.INFO, 'failed to open file: ' .. err)
  ngx.exit(ngx.HTTP_NOT_FOUND)
end

local file_length = f:seek('end')
local content_length = file_length - offset
if content_length < 0 then
  ngx.log(ngx.INFO, 'content_length is invalid: ' .. tostring(content_length) .. ' ('.. tostring(file_length) .. ' - ' .. tostring(offset) .. ')')
  ngx.exit(ngx.HTTP_BAD_REQUEST)
end
if limit ~= nil and content_length > limit then
  content_length = limit
end
ngx.header.content_length = content_length

-- Register the cleanup function on abort
local function on_abort()
  ngx.log(ngx.WARN, 'aborted by client')
  f:close()
  -- the exit code may not work if the header has been written by `ngx.print` already
  ngx.exit(499)
end
local ok, err = ngx.on_abort(on_abort)
if not ok then
  ngx.log(ngx.ERR, 'failed to register on_abort callback: ', err)
  ngx.exit(500)
end

-- Read from file and write to response body
f:seek('set', offset)
local read_bytes = 0
repeat
  local btr = chunk_size
  if (limit ~= nil) then
    if (limit - read_bytes <= 0) then
      break
    end
    btr = (limit - read_bytes) % chunk_size
  end
  local content = f:read(btr)
  if content == nil then
    break
  end
  read_bytes = read_bytes + #content
  ngx.print(content)
  ngx.flush(true)
until(false)
ngx.eof()
ngx.log(ngx.INFO, 'read ' .. tostring(read_bytes) .. ' / ' .. tostring(limit or 'all') .. ' bytes')

-- Clean up
f:close()
