local template = {}

function template.escape(data)
  return tostring(data or ''):gsub("[\">/<'&]", {
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ['"'] = "&quot;",
    ["'"] = "&#39;",
    ["/"] = "&#47;"
  })
end

function template.print(data, args, callback)
  local callback = callback or print
  local function exec(data)
    if type(data) == "function" then
      data(exec, args)
    else
      callback(tostring(data or ''))
    end
  end
  exec(data)
end

function template.parse(data)
  local str = 
    "return function(__, _)" .. 
      "function ___(...)" ..
        "__(require('template').escape(...))" ..
      "end " ..
      "__[=[\n" ..
      data:
        gsub("[][]=[][]", ']=]__"%1"__[=['):
        gsub("<%%%-=", "\n]=]__("):
        gsub("<%%=", "]=]__("):
        gsub("<%%%-", "\n]=]___("):
        gsub("<%%", "]=]___("):
        gsub("%-%%>", ")__[=[\n"):
        gsub("%%>", ")__[=["):
        gsub("<%?%-", "\n]=] "):
        gsub("<%?", "]=] "):
        gsub("%-%?>", " __[=[\n"):
        gsub("%?>", " __[=[") ..
      "]=] " ..
    "end"
  return str
end

function template.compile_file(path)
  local file = io.open(path)
  local file_content = file:read('*a')
  file:close()

  return loadstring(template.parse(file_content))()
end

function template.compile(...)
  return loadstring(template.parse(...))()
end

return template
