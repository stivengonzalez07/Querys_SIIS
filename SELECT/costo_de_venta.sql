SELECT
            d.empresa_id,
            d.centro_utilidad,
            d.bodega,
            c.departamento,
            e.grupo_id,
            e.clase_id,
            e.subclase_id,
            b.codigo_producto,
            c.centro_de_costo_id,
            SUM(CASE WHEN c.cargo = 'IMD'  THEN c.cantidad ELSE 0 END) as cantidad,
            SUM(CASE WHEN c.cargo = 'DIMD' THEN c.cantidad ELSE 0 END) as devolucion,
            SUM(CASE WHEN c.cargo = 'IMD'  THEN (b.cantidad * b.total_costo) ELSE 0 END) as costo_cargos,
            SUM(CASE WHEN c.cargo = 'DIMD'  THEN (b.cantidad * b.total_costo) ELSE 0 END) as costo_devoluciones,
            e.porc_iva AS porcentaje_iva
        FROM
            bodegas_documentos as a,
            bodegas_documentos_d as b,
            cuentas_detalle as c,
            bodegas_doc_numeraciones as d,
            inventarios_productos as e

        WHERE
           -- a.fecha >= _1 AND a.fecha <= _2
           ad.fecha >= '2021-11-18' AND ad.fecha <= '2021-11-19'
            AND b.bodegas_doc_id = a.bodegas_doc_id
            AND b.numeracion = a.numeracion
            AND c.consecutivo = b.consecutivo
            AND c.cargo IN ('IMD','DIMD')
            AND d.bodegas_doc_id = a.bodegas_doc_id
            AND d.empresa_id = '01'
            AND e.codigo_producto = b.codigo_producto
            AND a.sw_existencias = '1'

        GROUP BY 1,2,3,4,5,6,7,8,9,14