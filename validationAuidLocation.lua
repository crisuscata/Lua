function validateAuid(recursoValue, valueCompare, indicador, gt, grantType)

  v, one, segundoContexto, tercerContexto = string.match(recursoValue, '/(%a+)(%d+)/(%a+)/(%a+)')
  primerContexto = v .. one
  concatToCompare = "/"..primerContexto .. "/" .. segundoContexto .. "/".. tercerContexto
  
  if(concatToCompare == valueCompare) then
    return valIndicatorAndGt(indicador, gt, grantType)
  end
  
  return false

end

function valIndicatorAndGt(indicador, gt, grantType)
  
  if  (nil ==  indicador or '' == indicador) then
    return false
  end

  if  (nil ==  gt or '' == gt) then
    return false
  end

  if  (nil ==  grantType or '' == grantType) then
    return false
  end

  if(indicador == "0") then
    return valGt(gt, grantType)
  end

  if(indicador == "1") then
    if(grantType  ~= 'client_credentials') then
      return valGt(gt, grantType)
     else 
      return false
    end
  end

  return false

end

function valGt(gt, grantType)

  if(string.sub(gt, 1, 1) == '1') then

    if(grantType == 'password') then
      return true
    end

  end
  
  if(string.sub(gt, 2, 2) == '1') then

    if(grantType == 'client_credentials') then
      return true
    end

  end
  
  return false

end

function parseAud(aud)
	local cjson = require "cjson"
	return cjson.decode(aud)
end

------------------------------------------------------------------------------------------
--VALIDA PAYLOAD AUD
------------------------------------------------------------------------------------------
if  (nil ==  ngx.var.jwt_claim_aud or '' == ngx.var.jwt_claim_aud) then
	return 0
end

------------------------------------------------------------------------------------------
-- LOGICA VALIDA AUDIENCIA
------------------------------------------------------------------------------------------
local okParseAud, parseJsonAud = pcall(parseAud, ngx.var.jwt_claim_aud) 

if(not okParseAud) then
   return 0
end


local resultAud 	= false
local apiValue		= ngx.var.scheme .. "://" ..  ngx.var.host
local recursoValue	= ngx.var.uri

--OBTENIENDO SI EXISTE LA AUDIENCIA
for i, ivalue in pairs(parseJsonAud) do
	if(ivalue.api == apiValue) then
		for j, jrecurso in pairs(ivalue.recurso) do				
			if(validateAuid(recursoValue, jrecurso.id, jrecurso.indicador, jrecurso.gt, ngx.var.jwt_claim_grantType)) then
				resultAud = true			
				break
			end
		end
	end
end


if(resultAud) then
	return 1
else
	return 0
end