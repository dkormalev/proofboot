QMAKE_SPEC_T = $$[QMAKE_SPEC]
contains(QMAKE_SPEC_T,.*win.*) {
    win_host = 1
}

defineReplace(proof_plugin_dir_by_module) {
    return ($$system_path(Proof/$$1))
}

defineReplace(proof_plugin_destdir_by_module) {
    return ($$system_path($$BUILDPATH/imports/$$proof_plugin_dir_by_module($$1)))
}

defineTest(add_proof_module_includes) {
    MODULE_NAME = $$1
    contains(CONFIG, proof_internal):exists($$_PRO_FILE_PWD_/../proof.pro) {
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../$$MODULE_NAME))
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../$$MODULE_NAME/include))
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../$$MODULE_NAME/include/private))
        export(INCLUDEPATH)
    } else:contains(CONFIG, proof_internal):exists($$_PRO_FILE_PWD_/../../proof.pro) {
# TODO: remove after full switch to submodules
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../../$$MODULE_NAME))
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../../$$MODULE_NAME/include))
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../../$$MODULE_NAME/include/private))
        export(INCLUDEPATH)
    } else:contains(CONFIG, proof_internal):exists($$_PRO_FILE_PWD_/../../../proof.pro) {
# TODO: remove after full switch to submodules
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../../../$$MODULE_NAME))
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../../../$$MODULE_NAME/include))
        INCLUDEPATH *= $$clean_path($$system_path($$_PRO_FILE_PWD_/../../../$$MODULE_NAME/include/private))
        export(INCLUDEPATH)
    }
    return(true)
}

#Usage find_package(<pkgconfig package>[, <Macro definition if find>])
defineTest(find_package) {
    package = $$1
    macro = $$2

    isEmpty(package) {
        warning("$$TARGET: Wrong arguments. Usage: find_package(<pkgconfig package>[, <Macro definition if find>])")
        return (false)
    }
    isEmpty(macro){
        up = $$upper($$package)
        up = $$split(up,+)
        up = $$split(up,-)
        up = $$split(up,.)
        macro = $$join(up, _, , _FOUND)
    }
    contains(DEFINES, $$macro): return (true)

    # Can't use packagesExist because it always return true
    AVAILABILITY = $$system("pkg-config $$package --exists && echo true")
    equals(AVAILABILITY, "true") {
        AVAILABILITY = $$system("pkg-config $$package --print-requires --print-requires-private --print-errors --errors-to-stdout \
                                 || echo RequirementsFailure")
    } else:exists(/usr/local/lib/lib$$package*)|exists(/usr/lib/lib$$package*) {
        LIBS *=-l$$package
        DEFINES *= $$macro
        message("$$TARGET: Package '$$package' probably found. Macro defined $$macro")
        export(LIBS)
        export(DEFINES)
        return (true)
    }

    !equals(AVAILABILITY, "true") {
        contains(AVAILABILITY, "RequirementsFailure") {
            message("$$TARGET: Not found '$$package': $$AVAILABILITY")
            return (false)
        } else:!equals(AVAILABILITY, "") {
            REQ = "Requires: '$$AVAILABILITY'. "
        }
    }
    QT_CONFIG -= no-pkg-config
    CONFIG *= link_pkgconfig
    PKGCONFIG *= $$package
    DEFINES *= $$macro
    message("$$TARGET: Package '$$package' found. $${REQ}Macro defined $$macro")

    export(CONFIG)
    export(PKGCONFIG)
    export(DEFINES)
    return (true)
}