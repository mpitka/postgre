SELECT xmlelement(
    name "persons",
    xmlattributes(
		'v1.user-sync.pure.atira.dk' AS "xmlns",
        'v3.commons.pure.atira.dk' AS "xmlns:v3"
    ),
    xmlagg(
        xmlelement(
            name "person", xmlattributes(p.person_id),
            xmlelement(
                name "name",
                xmlelement(name "v3:firstname", p.first_name),
                xmlelement(name "v3:lastname", p.last_name)
            ),
            xmlelement(name "gender", gender),
			xmlelement(name "dateOfBirth", p.date_of_birth),
			xmlelement(name "nationality", p.nationality),
			xmlelement(name "employeeStartDate", employee_start_date),
			xmlelement(name "systemLeavingDate", system_leaving_date),
			xmlelement(name "academicProfessionEntry", academic_profession_entry),
            xmlelement(
                name "organisationAssociation",
                    
                CASE
                    WHEN sta.person_id IS NOT NULL THEN
                        xmlelement(
                            name "staffOrganisationAssociations", xmlattributes(sta.affiliation_id as id),
                            xmlelement(
                                name "organisation",
                                xmlelement(name "v3:source_id", sta.org_source_id)
                            ),
                            xmlelement(
                                name "period",
                                xmlelement(name "v3:startDate", sta.period_start_date),
                                xmlelement(name "v3:endDate", sta.period_end_date)
                            ),
                            xmlelement(name "staffType", sta.staff_type),
							xmlelement(name "contractType", sta.contract_type),							
							xmlelement(name "jobTitle", sta.job_title),
							xmlelement(name "jobDescription", sta.job_description),
							xmlelement(
								name "organisationAssociationType",
								xmlelement(name "employmentType", sta.employment_type)
							)
						)
                END,
                    
                CASE    
                    WHEN stu.person_id IS NOT NULL THEN
                        xmlelement(
                            name "studentOrganisationAssociations",	xmlattributes(stu.affiliation_id as id),
							xmlelement(
								name "organisation",
								xmlelement(name "v3:source_id", stu.org_source_id)
							),
							xmlelement(
								name "period",
								xmlelement(name "v3:startDate", stu.period_start_date),
								xmlelement(name "v3:endDate", stu.period_end_date)
							),
                            xmlelement(name "status", stu.status),
							xmlelement(name "start_year", stu.start_year),							
							xmlelement(name "programme", stu.programme),
							xmlelement(name "student_nationality", stu.student_nationality),
                            xmlelement(name "award_gained", stu.award_gained),
                            xmlelement(name "project_title_en", stu.project_title_en),
                            xmlelement(name "award_date", stu.award_date)
						)
                END,
                    
                CASE
                    WHEN hon.person_id IS NOT NULL THEN
                        xmlelement(
                            name "honoraryOrganisationAssociations", xmlattributes(hon.affiliation_id as id),
							xmlelement(
								name "organisation",
								xmlelement(name "v3:source_id", hon.org_source_id)
							),
							xmlelement(
								name "period",
								xmlelement(name "v3:startDate", hon.period_start_date),
								xmlelement(name "v3:endDate", hon.period_end_date)
							),
							xmlelement(name "staffType", hon.staff_type),
							xmlelement(name "employmentType", hon.employment_type),
							xmlelement(name "job_title", hon.job_title)
                        )
                END,
                    
                CASE
                    WHEN vis.person_id IS NOT NULL THEN
                        xmlelement(
                            name "visitingOrganisationAssociations", xmlattributes(vis.affiliation_id as id),
							xmlelement(
								name "organisation",
								xmlelement(name "v3:source_id", vis.org_source_id)
							),
							xmlelement(
								name "period",
								xmlelement(name "v3:startDate", vis.period_start_date),
								xmlelement(name "v3:endDate", vis.period_end_date)
							),
							xmlelement(name "employmentType", vis.employment_type),
							xmlelement(name "job_title", vis.job_title)
                        )
                END
            ),
			xmlelement(
                name "address",
				xmlelement(name "v3:country", country),
				xmlelement(name "v3:road", road),
				xmlelement(name "v3:room", room),
				xmlelement(name "v3:city", city),
				xmlelement(name "v3:building", building),
				xmlelement(name "v3:postalCode", postal_code)
			),
			xmlelement(name "affiliationNote", affiliation_note),			
			xmlelement(name "personIds", user_id),

			CASE
				WHEN p.orcid IS NOT NULL THEN
					xmlelement(
						name "orcId", 
						xmlelement(name "v1:orcId", orcid)
					)
			END,
			
			xmlelement(name "visibility", visibility),			
			xmlelement(
                name "personEducations",
				
				CASE    
					WHEN edu.person_id IS NOT NULL THEN
						xmlelement(
							name "personEducation",
							xmlelement(name "v3:qualification", edu.qualification),
							xmlelement(name "v3:awardDate", edu.award_date),
							xmlelement(name "v3:organisations", edu.org_source_id)
						)
				END
			),
			xmlelement(
                name "id",
				
				CASE
					WHEN ids.person_id IS NOT NULL THEN
						xmlelement(
							name "v3:type", xmlattributes(ids.type as type),
							xmlelement(name "v3:id", ids.id)
						)
				END
			)
        )
    )
)
FROM person_data p 
left join staff_org_relation sta on sta.person_id = p.person_id
left join student_org_relation stu on stu.person_id = p.person_id
left join honorary_staff_org_relation hon on hon.person_id = p.person_id
left join visiting_scholar_org_relation vis on vis.person_id = p.person_id
left join person_educations edu on edu.person_id = p.person_id
left join person_ids ids on ids.person_id = p.person_id
;