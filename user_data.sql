SELECT xmlelement(
    name "users",
    xmlattributes(
		'v1.user-sync.pure.atira.dk' AS "xmlns",
        'v3.commons.pure.atira.dk' AS "xmlns:v3"
    ),
    xmlagg(
        xmlelement(
            name "user",
            xmlattributes(id),
            xmlelement(name "userName", user_name),
            xmlelement(name "email", email),
            xmlelement(
                name "name",
                xmlelement(name "v3:firstname", first_name),
                xmlelement(name "v3:lastname", last_name)
            )
        )
    )
)
FROM user_data;