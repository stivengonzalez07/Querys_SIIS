--select * from (
SELECT 
SUM(CD.cantidad) AS cantidad,       
SUM(CD.valor_cargo) AS valor_cargo,       
SUM(CD.valor_nocubierto) AS valor_nocubierto,       
SUM(CD.valor_cubierto) AS valor_cubierto,       
SUM(CD.valor_descuento_empresa) AS valor_descuento_empresa,        
SUM(CD.valor_descuento_paciente) AS valor_descuento_paciente,        
'DESCARGO DE MEDICAMENTOS, INSUMOS Y/O DISPOSITIVOS' AS descripcion_grupo,      
 CD.empresa_id,        
 CD.centro_utilidad,        
 CD.bodega,        
 CD.codigo_producto,        
 CD.departamento,        
 CD.precio,       
 CD.porcentaje_gravamen,       
 fc_descripcion_producto(CD.codigo_producto) AS descripcion,        
 BS.bys_producto_id,       
 BS.bys_producto_descripcion 
 FROM   (            
     SELECT 
     SUM(CD.cantidad) AS cantidad,                  
     SUM(CD.valor_cargo) AS valor_cargo,                  
     SUM(CD.valor_nocubierto) AS valor_nocubierto,                  
     SUM(CD.valor_cubierto) AS valor_cubierto,                  
     SUM(CD.valor_descuento_empresa) AS valor_descuento_empresa,                   
     SUM(CD.valor_descuento_paciente) AS valor_descuento_paciente,                   
     BG.empresa_id,                   
     BG.centro_utilidad,                   
     BG.bodega,                   
     BG.descripcion AS descripcion_bodega,
     BD.codigo_producto,                  
     CD.departamento,                   
     CD.codigo_agrupamiento_id,                   
     CD.numerodecuenta,                   
     CD.precio,                   
     CD.porcentaje_gravamen            
     FROM   
     cuentas_detalle AS CD                   
     INNER JOIN bodegas_documentos_d BD ON(CD.consecutivo=BD.consecutivo)                   
     INNER JOIN bodegas_doc_numeraciones BN ON(BN.bodegas_doc_id=BD.bodegas_doc_id)                   
     INNER JOIN bodegas AS BG  
     ON( 
         BN.bodega=BG.bodega AND                       
         BN.centro_utilidad=BG.centro_utilidad AND                       
         BN.empresa_id=BG.empresa_id )            
         
         WHERE  CD.numerodecuenta = 406760   AND    CD.cargo = 'IMD'   AND     CD.facturado = '1'   AND     CD.paquete_codigo_id IS NULL            
         
         GROUP BY BD.codigo_producto,BG.empresa_id,BG.centro_utilidad,BG.bodega,CD.departamento,CD.codigo_agrupamiento_id,CD.numerodecuenta, CD.precio, CD.porcentaje_gravamen, BG.descripcion  
         UNION ALL  
           SELECT 
           SUM((CD.cantidad*(-1))) AS cantidad,                  
           SUM(CD.valor_cargo) AS valor_cargo,                  
           SUM(CD.valor_nocubierto) AS valor_nocubierto,                  
           SUM(CD.valor_cubierto) AS valor_cubierto,                  
           SUM(CD.valor_descuento_empresa) AS valor_descuento_empresa,                   
           SUM(CD.valor_descuento_paciente) AS valor_descuento_paciente,                   
           BG.empresa_id,                   
           BG.centro_utilidad,                   
           BG.bodega,                   
           BG.descripcion AS descripcion_bodega,                  
           BD.codigo_producto,                   
           CD.departamento,                   
           CD.codigo_agrupamiento_id,                   
           CD.numerodecuenta,                   
           CD.precio,                   
           CD.porcentaje_gravamen            
           FROM   cuentas_detalle AS CD                   
           INNER JOIN bodegas_documentos_d BD ON(CD.consecutivo=BD.consecutivo)                   
           INNER JOIN bodegas_doc_numeraciones BN ON(BN.bodegas_doc_id=BD.bodegas_doc_id)                   
           INNER JOIN bodegas AS BG                  
           ON( BN.bodega=BG.bodega AND                       
           BN.centro_utilidad=BG.centro_utilidad AND                       
           BN.empresa_id=BG.empresa_id )            
           WHERE  CD.numerodecuenta = 406760  AND    CD.cargo = 'DIMD'       AND     CD.facturado = '1'   AND  CD.paquete_codigo_id IS NULL            
           GROUP BY BD.codigo_producto,BG.empresa_id,BG.centro_utilidad,BG.bodega,CD.departamento,CD.codigo_agrupamiento_id,CD.numerodecuenta, CD.precio, CD.porcentaje_gravamen, BG.descripcion ) CD       
            INNER JOIN cuentas_codigos_agrupamiento CG ON (CD.codigo_agrupamiento_id=CG.codigo_agrupamiento_id)        
            INNER JOIN inventarios_productos IV ON (CD.codigo_producto=IV.codigo_producto)        
            LEFT JOIN bys_productos BS ON(IV.bys_producto_id = BS.bys_producto_id) 
           
           
           GROUP BY 7,8,9,10,11,12,13,14,15,16,17 ORDER BY CD.empresa_id,CD.centro_utilidad,CD.bodega,CD.codigo_producto

--)a where valor_cubierto != cantidad*precio