def _project_output(out: Artifact, path: str) -> Artifact:
    if path == ".":
        return out
    else:
        return out.project(path, hide_prefix=True)


def _gen_thrift(ctx: AnalysisContext) -> list[Provider]:
    out_artifact = ctx.actions.declare_output("out", dir=True)
    lang = ctx.attrs.lang
    srcs = []
    headers = []
    for src in ctx.attrs.srcs:
        source_file = src.short_path.removesuffix(".thrift")
        gen_name = "".join([part.capitalize() for part in source_file.split("_")])
        if lang == "cpp":
            srcs += [
                _project_output(out_artifact, gen_name + ".cpp"),
            ]
            headers += [
                _project_output(out_artifact, gen_name + ".h"),
                _project_output(out_artifact, source_file + "_types.h"),
            ]
        elif lang == "py":
            srcs += [
                _project_output(out_artifact, source_file + "/" + gen_name + ".py"),
                _project_output(out_artifact, source_file + "/" + "constants.py"),
                _project_output(out_artifact, source_file + "/" + "ttypes.py"),
            ]
        else:
            fail("Unsupported language {} (not implemented yet)".format(lang))

    base_thrift_cmd = "thrift -r --gen {}".format(lang)

    thrift_cmds = cmd_args(
        ctx.attrs.srcs, format=base_thrift_cmd + " --out $OUT {}"
    )
    script = [
        cmd_args(out_artifact, format="mkdir -p {}"),
        thrift_cmds,
    ]

    # Writing the script to a file helps with debugging
    sh_script, _ = ctx.actions.write(
        "sh/gen_thrift.sh",
        script,
        is_executable = True,
        allow_args = True,
    )

    script_args = ["/usr/bin/env", "bash", "-e", sh_script]
    env_vars = {
        "OUT": cmd_args(out_artifact.as_output()),
    }
    outputs = srcs + headers

    ctx.actions.run(
        cmd_args(sh_script, hidden = [output.as_output() for output in outputs]),
        env = env_vars,
        category = "gen_thrift",
    )
    return [DefaultInfo(
        default_outputs = srcs,
        sub_targets = {
            "generated_sources": [DefaultInfo(default_outputs = srcs)],
            "generated_headers": [DefaultInfo(default_outputs = headers)],
        },
    )]

gen_thrift = rule(
    impl = _gen_thrift,
    attrs = {
        "srcs": attrs.list(attrs.source()),
        "lang": attrs.string(),
    }
)

def thrift_library(name, srcs, languages, deps = [], visibility = [], **kwargs):
    for lang in languages:
        if lang == "cpp":
            cxx_thrift_library(
                name = name,
                srcs = srcs,
                deps = deps,
                visibility = visibility,
            )
        elif lang == "py":
            py_thrift_library(
                name = name,
                srcs = srcs,
                visibility = visibility,
            )
        else:
            fail("Unsupported language {} (not implemented yet)".format(lang))

        gen_thrift(
            name = "{}-{}-gen".format(name, lang),
            srcs = srcs,
            lang = lang,
            visibility = visibility,
        )

def cxx_thrift_library(name, srcs, deps = [], visibility = []):
    native.cxx_library(
        name = "{}-cpp".format(name),
        srcs = [
            ":{}-cpp-gen[generated_sources]".format(name),
        ],
        headers = [
            ":{}-cpp-gen[generated_headers]".format(name),
        ],
        exported_headers = [
            ":{}-cpp-gen[generated_headers]".format(name),
        ],
        # i.e. if your build target is //foo/bar:target
        # the cpp include would be
        # #include "foo/bar/gen-cpp/NameInUpperCamelCase.cpp"
        header_namespace = "{}/gen-cpp".format(package_name()),
        visibility = visibility,
        exported_deps = deps,
        compiler_flags = ["-std=c++20"],
    )

def py_thrift_library(name, srcs, visibility = []):
    native.python_library(
        name = "{}-py".format(name),
        srcs = [
            ":{}-py-gen[generated_sources]".format(name),
        ],
        base_module = "",
        visibility = visibility,
    )
