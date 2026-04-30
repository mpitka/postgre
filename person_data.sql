-- dbsync -> Pure

WITH person_ids_agg AS (
    SELECT person_id,
        xmlagg(
            xmlelement(
                name "v3:id", xmlattributes(id AS id, type AS type), value
            )
        ) AS ids_xml FROM person_ids GROUP BY person_id
),
person_names_agg AS (
    SELECT person_id,
	xmlagg(
		xmlelement(
			name "classifiedName", xmlattributes(id AS id),
			xmlelement(
				name "name",
				xmlelement(name "v3:firstname", first_name),
				xmlelement(name "v3:lastname", last_name)
			),
			xmlelement(name "typeClassification", type)
		)
	) AS names_xml FROM person_names GROUP BY person_id
),
sta_agg AS (
    SELECT person_id,
	xmlagg(
		xmlelement(
			name "staffOrganisationAssociation", xmlattributes(id as id),
			xmlelement(name "affiliationId", affiliation_id),
			xmlelement(name "employmentType", employment_type),
			xmlelement(name "primaryAssociation", primary_association),
			xmlelement(
				name "organisation",
				xmlelement(name "v3:source_id", org_source_id)
			),
			xmlelement(
				name "period",
				xmlelement(name "v3:startDate", period_start_date),
				CASE
					WHEN period_end_date IS NOT NULL THEN
						xmlelement(name "v3:endDate", period_end_date)
				END
			),
			xmlelement(name "staffType", staff_type),
			CASE
				WHEN contract_type IS NOT NULL THEN
					xmlelement(name "contractType", contract_type)
			END,
			xmlelement(name "jobTitle", job_title),
			xmlelement(
				name "jobDescription", 
				xmlelement(name "v3:text", job_description)
			)
		)
	) AS sta_xml FROM staff_org_relation GROUP BY person_id
),
stu_agg AS (
    SELECT person_id,
	xmlagg(
		xmlelement(
			name "studentOrganisationAssociation",	xmlattributes(affiliation_id as id),
			xmlelement(
				name "organisation",
				xmlelement(name "v3:source_id", org_source_id)
			),
			xmlelement(
				name "period",
				xmlelement(name "v3:startDate", period_start_date),
				CASE
					WHEN period_end_date IS NOT NULL THEN
						xmlelement(name "v3:endDate", period_end_date)
				END
			),
			CASE
				WHEN status IS NOT NULL THEN
					xmlelement(name "status", status)
			END,
			CASE
				WHEN start_year IS NOT NULL THEN
					xmlelement(name "startYear", start_year)							
			END,
			CASE
				WHEN programme IS NOT NULL THEN
					xmlelement(name "programme", programme)
			END,
			-- CASE
			--	WHEN student_nationality IS NOT NULL OR student_nationality <>'' THEN
			--		xmlelement(name "studentNationality", student_nationality)
			-- END,
			CASE
				WHEN award_gained IS NOT NULL THEN
					xmlelement(name "awardGained", award_gained)
			END,
			CASE
				WHEN project_title_en IS NOT NULL THEN
					xmlelement(name "projectTitle", project_title_en)
			END,
			CASE
				WHEN award_date IS NOT NULL THEN
					xmlelement(name "awardDate", award_date)
			END
		)
	) AS stu_xml FROM student_org_relation GROUP BY person_id
),
hon_agg AS (
    SELECT person_id,
	xmlagg(
		 xmlelement(
			name "honoraryOrganisationAssociation", xmlattributes(affiliation_id as id),
			xmlelement(
				name "organisation",
				xmlelement(name "v3:source_id", org_source_id)
			),
			xmlelement(
				name "period",
				xmlelement(name "v3:startDate", period_start_date),
				CASE
					WHEN period_end_date IS NOT NULL THEN
						xmlelement(name "v3:endDate", period_end_date)
				END
			),
			xmlelement(name "staffType", staff_type),
			xmlelement(name "employmentType", employment_type),
			xmlelement(name "job_title", job_title)
		)
	) AS hon_xml FROM honorary_staff_org_relation GROUP BY person_id
),
vis_agg AS (
    SELECT person_id,
	xmlagg(
		 xmlelement(
			name "visitingOrganisationAssociation", xmlattributes(affiliation_id as id),
			xmlelement(
				name "organisation",
				xmlelement(name "v3:source_id", org_source_id)
			),
			xmlelement(
				name "period",
				xmlelement(name "v3:startDate", period_start_date),
				CASE
					WHEN period_end_date IS NOT NULL THEN
						xmlelement(name "v3:endDate", period_end_date)
				END
			),
			xmlelement(name "employmentType", employment_type),
			xmlelement(name "job_title", job_title)
		)
	) AS vis_xml FROM visiting_scholar_org_relation GROUP BY person_id
),
person_edu_agg AS (
    SELECT person_id,
    xmlagg(
		xmlelement(
			name "personEducation", xmlattributes(id AS id),
			xmlelement(name "qualification", qualification),
			xmlelement(name "awardDate", award_date),
			xmlelement(name "organisations",
				xmlelement(name "organisation",
					xmlelement(name "v3:source_id", org_source_id)
				)
			)
		)
	) AS edu_xml FROM person_educations GROUP BY person_id
),
person_kw_agg AS (
    SELECT person_id,
    xmlagg(
		xmlelement(
			name "v3:logicalGroup", xmlattributes(logical_name AS "logicalName"),
			xmlelement(
				name "v3:structuredKeywords",
				xmlelement(name "v3:structuredKeyword", xmlattributes(type AS classification))
			)
		)
	) AS kw_xml FROM person_keywords GROUP BY person_id
)


SELECT xmlelement(
    name "persons",
    xmlattributes(
		'v1.unified-person-sync.pure.atira.dk' AS "xmlns",
        'v3.commons.pure.atira.dk' AS "xmlns:v3"
    ),
    xmlagg(
        xmlelement(
            name "person", xmlattributes(p.person_id as id),
            xmlelement(
                name "name",
                xmlelement(name "v3:firstname", p.first_name),
                xmlelement(name "v3:lastname", p.last_name)
            ),
			xmlelement(
				name "names", n.names_xml

            ),
			
            xmlelement(name "gender", gender),

			CASE
				WHEN p.date_of_birth IS NOT NULL THEN
					xmlelement(name "dateOfBirth", p.date_of_birth)
			END,
			CASE
				WHEN p.nationality IS NOT NULL THEN
					xmlelement(name "nationality", p.nationality)
			END,
			CASE
				WHEN p.employee_start_date IS NOT NULL THEN
					xmlelement(name "employeeStartDate", employee_start_date)
			END,
			CASE
				WHEN p.system_leaving_date IS NOT NULL THEN
					xmlelement(name "systemLeavingDate", system_leaving_date)
			END,
			CASE
				WHEN p.academic_profession_entry IS NOT NULL THEN
					xmlelement(name "academicProfessionEntry", academic_profession_entry)
			END,

			xmlelement(
                name "privateAddress",
				CASE
					WHEN p.country IS NOT NULL THEN
						xmlelement(name "v3:country", p.country)
				END,
				CASE
					WHEN p.road IS NOT NULL THEN
						xmlelement(name "v3:road", p.road)
				END,
				CASE
					WHEN p.room IS NOT NULL THEN
						xmlelement(name "v3:room", p.room)
				END,
				CASE
					WHEN p.city IS NOT NULL THEN
						xmlelement(name "v3:city", p.city)
				END,
				CASE
					WHEN p.building IS NOT NULL THEN
						xmlelement(name "v3:building", p.building)
				END,
				CASE
					WHEN p.postal_code IS NOT NULL THEN
						xmlelement(name "v3:postalCode", p.postal_code)
				END
			),

            xmlelement(
                name "organisationAssociations",
                    
                CASE
                    WHEN sta.person_id IS NOT NULL THEN	sta.sta_xml
				END,
                    
                CASE    
                    WHEN stu.person_id IS NOT NULL THEN stu.stu_xml
                END,
                    
                CASE
                    WHEN hon.person_id IS NOT NULL THEN hon.hon_xml
                END,
                    
                CASE
                    WHEN vis.person_id IS NOT NULL THEN vis.vis_xml
				END
            ),
			
			CASE
				WHEN p.affiliation_note IS NOT NULL THEN
					xmlelement(name "affiliationNote", p.affiliation_note)
			END,

			CASE    
				WHEN edu.person_id IS NOT NULL THEN
					xmlelement(name "personEducations", edu.edu_xml)
			END,
			
			CASE
				WHEN kw.person_id IS NOT NULL THEN
					xmlelement(name "keywords", kw.kw_xml)
			END,

			xmlelement(name "personIds", ids.ids_xml),

			CASE
				WHEN p.orcid IS NOT NULL THEN
					xmlelement(
						name "orcId", 
						xmlelement(name "v1:orcId", orcid)
					)
			END,

			xmlelement(name "visibility", initcap(visibility))
        )
    )
)
FROM person_data p 
left join person_ids_agg ids on ids.person_id = p.person_id
left join person_names_agg n on n.person_id = p.person_id
left join sta_agg sta on sta.person_id = p.person_id
left join stu_agg stu on stu.person_id = p.person_id
left join hon_agg hon on hon.person_id = p.person_id
left join vis_agg vis on vis.person_id = p.person_id
left join person_edu_agg edu on edu.person_id = p.person_id
left join person_kw_agg kw on kw.person_id = p.person_id
where p.person_id='101079';