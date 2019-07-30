package js.npm.aws_sdk;

import haxe.Constraints;

@:jsRequire("aws-sdk", "S3")
extern class S3 {
    public function new(?options:Dynamic):Void;
    public function listObjectsV2(?params:Dynamic, ?callback:Dynamic):Request;
    public function getObject(?params:Dynamic, ?callback:Dynamic):Request;
}
