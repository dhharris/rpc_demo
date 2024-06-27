load("//build_defs:gencode.bzl", "gencode")
load("//build_defs:gencode.bzl", "cpp_gencode_library")
load("//build_defs:gencode.bzl", "python_gencode_library")

def _get_thrift_gen_srcs(lang: str, src: Artifact) -> list[str]:
    source_file = src.short_path.removesuffix(".thrift")
    gen_name = "".join([part.capitalize() for part in source_file.split("_")])
    if lang == "cpp":
        return ["{}.cpp".format(gen_name)]
    elif lang == "py":
        return [
            "{}/{}.py".format(source_file, gen_name),
            "{}/constants.py".format(source_file),
            "{}/ttypes.py".format(source_file),
        ]
    else:
        fail("Unsupported language {} (not implemented yet)".format(lang))

def _get_thrift_gen_headers(lang: str, src: Artifact) -> list[str]:
    source_file = src.short_path.removesuffix(".thrift")
    gen_name = "".join([part.capitalize() for part in source_file.split("_")])
    if lang == "cpp":
        return [
            "{}.h".format(gen_name),
            "{}_types.h".format(source_file),
        ]
    return []


def _thrift_gencode(ctx: AnalysisContext) -> list[Provider]:
    # Due to limitations of buck, we must be explicit with where the generated
    # sources / headers live. This function facilitates that using subtargets.
    lang = ctx.attrs.lang
    srcs = []
    headers = []
    for src in ctx.attrs.srcs:
        srcs += _get_thrift_gen_srcs(lang, src)
        headers += _get_thrift_gen_headers(lang, src)

    cmd = "thrift -r --gen {} --out $OUT".format(lang)
    return gencode(
        ctx,
        # Creates a list of commands with each source file
        cmd_args(ctx.attrs.srcs, format=cmd + " {}"),
        srcs,
        headers
    )

gen_thrift = rule(
    impl = _thrift_gencode,
    attrs = {
        "srcs": attrs.list(attrs.source()),
        "lang": attrs.string(),
    }
)

def thrift_library(name, srcs, languages, deps = [], visibility = [], **kwargs):
    for lang in languages:
        if lang == "cpp":
            cpp_gencode_library(
                name = name,
                srcs = srcs,
                deps = deps,
                visibility = visibility,
            )
        elif lang == "py":
            python_gencode_library(
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
