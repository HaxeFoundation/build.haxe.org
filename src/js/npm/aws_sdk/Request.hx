package js.npm.aws_sdk;

@:jsRequire("aws-sdk", "Request")
extern class Request {
    public function on(event:String, callb:haxe.Constraints.Function):js.Promise<Dynamic>;
    public function send(?callb:haxe.Constraints.Function):js.Promise<Dynamic>;
    public function promise():js.Promise<Dynamic>;
    public function createReadStream():js.node.Stream<Dynamic>;
}