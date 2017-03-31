$.getJSON("project.json", function (data) {
	console.log("load_json before");

	var items = [];
	$.each(data, function (key, val) {
		items.push("<li id='" + key + "'>" + val + "</li>");
	});

	$("<ul/>", {
		"class": "my-new-list",
		html: items.join("")
	}).appendTo("body");

	console.log("load_json before");
});
