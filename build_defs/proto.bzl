load("//build_defs:gencode.bzl", "gencode")
load("//build_defs:gencode.bzl", "cpp_gencode_library")
load("//build_defs:gencode.bzl", "python_gencode_library")

def _get_proto_gen_srcs(lang: str, src: Artifact) -> list[str]:
    source_file = src.short_path.removesuffix(".proto")
    if lang == "cpp":
        return [
            "{}.pb.cc".format(source_file),
            "{}.grpc.pb.cc".format(source_file),
        ]
    elif lang == "py":
        return [
            "{}_pb2.py".format(source_file),
            "{}_pb2_grpc.py".format(source_file),
        ]
    else:
        fail("Unsupported language {} (not implemented yet)".format(lang))

def _get_proto_gen_headers(lang: str, src: Artifact) -> list[str]:
    source_file = src.short_path.removesuffix(".proto")
    if lang == "cpp":
        return [
            "{}.pb.h".format(source_file),
            "{}.grpc.pb.h".format(source_file),
        ]
    return []


def _proto_grpc_gencode(ctx: AnalysisContext) -> list[Provider]:
    lang = ctx.attrs.lang
    srcs = []
    headers = []
    for src in ctx.attrs.srcs:
        srcs += _get_proto_gen_srcs(lang, src)
        headers += _get_proto_gen_headers(lang, src)

    if lang == "py":
        lang = "python"
    # By default protoc generates files with a full directory tree
    # -I {package_name()} fixes this behavior, but cannot be called in
    # analysis so we include it in ctx.attrs.path
    cmd = "protoc -I {} --{}_out $OUT --grpc_out $OUT --plugin=protoc-gen-grpc=$(which grpc_{}_plugin)".format(ctx.attrs.path, lang, lang)
    return gencode(
        ctx,
        # Creates a list of commands with each source file
        cmd_args(ctx.attrs.srcs, format=cmd + " {}"),
        srcs,
        headers
    )

gen_proto_grpc = rule(
    impl = _proto_grpc_gencode,
    attrs = {
        "srcs": attrs.list(attrs.source()),
        "lang": attrs.string(),
        "path": attrs.string(),
    }
)

# N.B. Could have a similar implementation for proto without gRPC
def proto_grpc_library(name, srcs, languages, deps = [], visibility = [], **kwargs):
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

        gen_proto_grpc(
            name = "{}-{}-gen".format(name, lang),
            srcs = srcs,
            lang = lang,
            path = package_name(),
            visibility = visibility,
        )
