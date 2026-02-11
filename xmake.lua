-- lsp: xmake project -k compile_commands --lsp=clangd --outputdir=build
-- build: xmake build
--
-- Expected dependency layout (relative to <repo_root>)
--
-- <parent_dir>/
-- ├─ hkxcmd/                ← <repo_root>
-- │   ├─ Core/
-- │   ├─ Addins/
-- │   ├─ Compat/
-- │   ├─ Loki/
-- │   │   ├─ include/
-- │   │   └─ src/
-- │   ├─ niflib/
-- │   │   └─ src/
-- │   ├─ zlib/
-- │   ├─ xmake.lua
-- │   └─ ...
-- │
-- └─ Havok SDK/
--     └─ 2010_2_0/
--         ├─ Source/
--         └─ Lib/
--             └─ win32_net_9-0/
--                 ├─ debug_multithreaded/
--                 │   └─ *.lib
--                 └─ release_multithreaded/
--                     └─ *.lib
add_rules("mode.debug", "mode.release")

-- Global settings (declared here to be inherited by niflib)
set_arch("x86") -- Because it depends on Havok's x86 static.lib
set_runtimes("MT") -- Prioritizing portability, including C Runtime itself

includes("niflib")

-- No need to set `set_languages("cxx11")` since C++11 is the default.
target("hkxcmd", function()
	add_deps("niflib_static")

	set_pcxxheader("Core/stdafx.h") -- Precompiled header
	add_includedirs(
		"Core",
		"Compat",
		"Loki/include",
		"../Havok SDK/2010_2_0/Source",
		"../Havok SDK/2010_2_0/compat",
		{ public = true }
	)

	add_files("Addins/*.cpp", "Compat/*.cpp", "Core/*.cpp", "Loki/src/*.cpp", "zlib/*.c|minigzip.c")

	add_defines(
		"WIN32",
		"_CRT_SECURE_NO_DEPRECATE",
		"_CRT_NONSTDC_NO_DEPRECATE",
		"_SCL_SECURE_NO_WARNINGS",
		"USE_NIFLIB_TEMPLATE_HELPERS",
		"NIFLIB_STATIC_LINK"
	)
	if is_mode("debug") then
		add_defines("_DEBUG", "_CONSOLE")
	else
		add_defines("NDEBUG")
	end

	-- MSVC-specific flags
	if is_plat("windows") and is_kind("static") then
		add_cxxflags("/wd4828") -- Turn off Invalid utf-8 warning temporary
		add_cxflags("/utf-8", "/bigobj", "/EHsc", { force = true })
	end

	-- Havok libraries
	if is_mode("debug") then
		add_linkdirs("../Havok SDK/2010_2_0/Lib/win32_net_9-0/debug_multithreaded")
	else
		add_linkdirs("../Havok SDK/2010_2_0/Lib/win32_net_9-0/release_multithreaded")
	end
	add_links({
		"hkaAnimation",
		"hkaInternal",
		"hkaRagdoll",
		"hkBase",
		"hkCompat",
		"hkgBridge",
		"hkgCommon",
		"hkgDx10",
		"hkgDx9",
		"hkgDx9s",
		"hkGeometryUtilities",
		"hkgOgl",
		"hkgOglES",
		"hkgOglES2",
		"hkgOgls",
		"hkInternal",
		"hkpCollide",
		"hkpConstraintSolver",
		"hkpDynamics",
		"hkpInternal",
		"hkpUtilities",
		"hkpVehicle",
		"hkSceneData",
		"hksCommon",
		"hkSerialize",
		"hksXAudio2",
		"hkVisualize",
	})

	-- Old Compatibility
	add_links("oldnames", "legacy_stdio_definitions", "libucrt")

	before_build(function(_target)
		local subwcrev_path = os.getenv("PROGRAMFILES") .. "/TortoiseSVN/bin/SubWCRev.exe"
		if os.isfile(subwcrev_path) then
			os.execf('"%s" . Core/config.h.in Core/config.h > nul 2>&1', subwcrev_path)
			print("Generated Core/config.h via SubWCRev")
		else
			print("SubWCRev not found, skipping config.h generation")
		end
	end)
end)
