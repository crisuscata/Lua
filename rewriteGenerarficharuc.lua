local cjson = require "cjson"
local jwt = require "resty.jwt"

local auth_header = ngx.var.http_Authorization
if auth_header then
	_, _, token = string.find(auth_header, "Bearer%s+(.+)")
end


if  (nil ~=  token) then
	--GET JWT IN STRING
	 local jwt_obj = jwt:verify("lua-resty-jwt", token)
	 local encode  = cjson.encode(jwt_obj)
	--PARSING JSON
	 local parseJsonJWT = cjson.decode(encode)
	 ngx.req.set_header("Coddepend", parseJsonJWT.payload.userdata.codDepend)
	 ngx.req.set_header("Numruc", parseJsonJWT.payload.userdata.numRUC)
	 ngx.req.set_header("Login", parseJsonJWT.payload.userdata.login)
	 ngx.req.set_uri("/v1/contribuyente/registro/t/emisionreporte/generarficharuc")
end