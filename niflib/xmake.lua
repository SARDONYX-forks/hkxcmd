target("niflib_static", function()
	set_kind("static")
	set_languages("cxx14") -- required. To avoid std::bytes error

	add_defines("NIFLIB_STATIC_LINK")

	add_includedirs("src/include", "src/src", { public = true })
	add_links("niflib_static", { public = true })

	add_files("src/src/**.cpp", "src/NvTriStrip/**.cpp", "src/TriStripper/**.cpp")

	if is_plat("windows") then
		add_cxxflags("/wd4828") -- Turn off Invalid utf-8 warning temporary
		add_cxxflags("/wd4251", "/wd4275", { force = true })
	end
end)
