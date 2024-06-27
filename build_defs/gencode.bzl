def _project_output(out: Artifact, path: str) -> Artifact:
    if path == ".":
        return out
    else:
        return out.project(path, hide_prefix=True)

def gencode(ctx: AnalysisContext, cmd: cmd_args, generated_sources: list[str], generated_headers: list[str]) -> list[Provider]:
    # This method is used for generating code in various languages.
    #
    # param: cmd
    # We provide an environment variable $OUT that specifies the output location
    #
    # param: generated_sources / headers
    # Due to limitations of buck, we must be explicit with where the generated
    # sources / headers live. They will then be passed to the caller using subtargets.
    # i.e. :my-gen-rule[generated_headers]
    #
    # Basic example:
    # return gencode(
    #     ctx,
    #     cmd_args(ctx.attrs.srcs, format="python generate_sources.py -o $OUT {}"),
    #     ["SourceFile.cpp"],
    #     ["Header.h"])
    # )
    out_artifact = ctx.actions.declare_output("out", dir=True)
    srcs = [
        _project_output(out_artifact, name)
        for name in generated_sources
    ]
    headers = [
        _project_output(out_artifact, name)
        for name in generated_headers
    ]

    script = [
        cmd_args(out_artifact, format="mkdir -p {}"),
        cmd,
    ]

    # Writing the script to a file helps with debugging
    sh_script, _ = ctx.actions.write(
        "sh/gencode.sh",
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
        category = "gencode",
    )
    return [DefaultInfo(
        default_outputs = srcs,
        sub_targets = {
            "generated_sources": [DefaultInfo(default_outputs = srcs)],
            "generated_headers": [DefaultInfo(default_outputs = headers)],
        },
    )]

def cpp_gencode_library(name, srcs, deps = [], visibility = []):
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

def python_gencode_library(name, srcs, visibility = []):
    native.python_library(
        name = "{}-py".format(name),
        srcs = [
            ":{}-py-gen[generated_sources]".format(name),
        ],
        base_module = "",
        visibility = visibility,
    )
