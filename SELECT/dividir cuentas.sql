SELECT 
cd.transaccion , 
bd.codigo_producto , 
cd.numerodecuenta ,
cd.cargo,
cd.departamento , 
cd.cantidad , 
cd.precio 
FROM 
cuentas_detalle cd INNER JOIN bodegas_documentos_d bd ON cd.consecutivo=bd.consecutivo 
WHERE 
cd.numerodecuenta=404324   
AND bd.codigo_producto='0201010441' 
ORDER BY cd.departamento

---------------------------------

SELECT cd.*, bd.*
FROM cuentas_detalle cd
INNER JOIN bodegas_documentos_d bd ON cd.consecutivo=bd.consecutivo
WHERE cd.numerodecuenta=404324  AND bd.codigo_producto='0201010441'
ORDER BY cd.departamento