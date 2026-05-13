-- organisations: dbsync -> Pure

WITH org_ids_agg AS (
    SELECT organisation_id,
	xmlagg(
		xmlelement(name "id",
			xmlelement(name "idSource", id_source),
			xmlelement(name "id", id)						
		)
	) AS ids_xml FROM organisation_ids GROUP BY organisation_id
),
org_namev_agg AS (
    SELECT organisation_id, name_variant_en, name_variant_fi,
	xmlagg(
		xmlelement(
			name "nameVariant",
			xmlelement(name "type", type),
			xmlelement(name "name",
				xmlelement(name	"v3:text", xmlattributes('en' as lang, 'GB' as country), name_variant_en),
				xmlelement(name	"v3:text", xmlattributes('fi' as lang, 'FI' as country), name_variant_fi)
			)
		)
	) AS names_xml FROM organisation_name_variants GROUP BY organisation_id, name_variant_en, name_variant_fi
),
org_hier_agg AS (
    SELECT child_organisation_id,
	xmlagg(
		xmlelement(name "parentOrganisationId", parent_organisation_id)
	) AS hier_xml FROM organisation_hierarchy GROUP BY child_organisation_id
)



SELECT xmlelement(
    name "organisations",
    xmlattributes(
		'v1.organisation-sync.pure.atira.dk' AS "xmlns",
        'v3.commons.pure.atira.dk' AS "xmlns:v3"
    ),
    xmlagg(
        xmlelement(
            name "organisation",
	            xmlelement(name "organisationId", o.organisation_id),
				xmlelement(name "type", o.type),
	            xmlelement(name "name", 
				CASE
					WHEN o.name_en IS NOT NULL THEN
						xmlelement(name "v3:text", xmlattributes('en' as lang, 'GB' as country), name_en)
				END,
				CASE
					WHEN o.name_fi IS NOT NULL THEN
						xmlelement(name "v3:text", xmlattributes('fi' as lang, 'FI' as country), name_fi)
				END ),
				xmlelement(name "startDate", o.start_date),
				CASE
					WHEN o.end_date IS NOT NULL THEN
		                xmlelement(name "endDate", o.end_date)
				END,
				
				xmlelement(name "visibility", 'Restricted'), --initcap(o.visibility))
				
				CASE
					WHEN o.owner IS NOT NULL THEN
						xmlelement(name "owner", o.owner)
				END,

				CASE
					WHEN h.child_organisation_id IS NOT NULL THEN
			            h.hier_xml
				END,

				CASE
					WHEN n.name_variant_en IS NOT NULL OR n.name_variant_fi IS NOT NULL THEN
						xmlelement(name "nameVariants", n.names_xml)
				END,

				CASE
					WHEN ids.organisation_id IS NOT NULL THEN
						xmlelement(name "ids", ids.ids_xml)
				
		)
	)
)

FROM organisation_data o 
left join org_ids_agg ids on ids.organisation_id = o.organisation_id
left join org_namev_agg n on n.organisation_id = o.organisation_id
left join org_hier_agg h on h.child_organisation_id = o.organisation_id;
--where o.organisation_id='LAI_109_2013-01-01';