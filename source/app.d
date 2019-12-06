import std.base64;
import std.regex;
import std.stdio;
import std.string;
import vibe.vibe;

void main() {
	listenHTTP(":80", &handleRequest);
	runApplication();
}

void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
	try {
		writeln(req.path);
		if (req.path.startsWith("/MinecraftSkins/")) {
			auto a = matchFirst(req.path, ctRegex!(`/MinecraftSkins/([a-zA-Z0-9_]+).png`));
			if (a.empty || a.length != 2) return;
			string s = a[1];
			Json j = requestHTTP("https://api.mojang.com/users/profiles/minecraft/" ~ s).readJson();
			string uuid = j["id"].get!string;
			j = requestHTTP("https://sessionserver.mojang.com/session/minecraft/profile/" ~ uuid).readJson();
			string value = j["properties"][0]["value"].get!string;//I hope there's only ever one
			j = parseJsonString(cast(string) Base64.decode(value));
			string url = j["textures"]["SKIN"]["url"].get!string;
			res.redirect(url);
		} else if (req.path.startsWith("/MinecraftCloaks/")) {
			auto a = matchFirst(req.path, ctRegex!(`/MinecraftCloaks/([a-zA-Z0-9_]+).png`));
			if (a.empty || a.length != 2) return;
			string s = a[1];
			Json j = requestHTTP("https://api.mojang.com/users/profiles/minecraft/" ~ s).readJson();
			string uuid = j["id"].get!string;
			j = requestHTTP("https://sessionserver.mojang.com/session/minecraft/profile/" ~ uuid).readJson();
			string value = j["properties"][0]["value"].get!string;//I hope there's only ever one
			j = parseJsonString(cast(string) Base64.decode(value));
			string url = j["textures"]["CAPE"]["url"].get!string;
			res.redirect(url);
		} else {
			res.redirect("http://52.216.109.61" ~ req.path);
		}
	} catch(Exception e) {
		res.redirect("http://52.216.109.61" ~ req.path);
	}
}