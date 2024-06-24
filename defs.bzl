def _project_output(out: Artifact, path: str) -> Artifact:
    if path == ".":
        return out
    else:
        return out.project(path, hide_prefix=True)


def _gen_thrift(ctx: AnalysisContext) -> list[Provider]:
    out_artifact = ctx.actions.declare_output("out", dir=True)
    srcs = []
    headers = []
    for src in ctx.attrs.srcs:
        source_file = src.short_path.removesuffix(".thrift")
        gen_name = "".join([part.capitalize() for part in source_file.split("_")])
        srcs += [
            _project_output(out_artifact, gen_name + ".cpp"),
        ]
        headers += [
            _project_output(out_artifact, gen_name + ".h"),
            _project_output(out_artifact, source_file + "_types.h"),
        ]

    thrift_cmds = cmd_args(
        ctx.attrs.srcs, format="thrift -r --gen cpp --gen py --out $OUT {}"
    )
    script = [
        cmd_args(out_artifact, format="mkdir -p {}"),
        thrift_cmds,
    ]

    # Writing the script to a file helps with debugging
    sh_script, _ = ctx.actions.write(
        "sh/thrift_gen_cpp.sh",
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
        category = "thrift_gen_cpp",
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
    }
)
