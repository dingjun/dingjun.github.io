$.getJSON("json/projects.json", function (data) {
	var projects = [];
	$.each(data, function (key, val) {
		projects.push("<li>--Project--</li>");
		projects.push("<li>" + key + "</li>");
		projects.push("<li>" + val.title + "</li>");
		projects.push("<li>" + val.link + "</li>");
		projects.push("<li>" + val.image + "</li>");
		projects.push("<li>" + val.description + "</li>");
		projects.push("<br>");
	});

	$("<ul/>", {
		"class": "my-new-list",
		html: projects.join("")
	}).appendTo("body");
});
