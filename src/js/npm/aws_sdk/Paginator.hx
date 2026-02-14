package js.npm.aws_sdk;

import js.lib.Promise;
import js.lib.Iterator;

extern class Paginator<T> {
    function next():Promise<IteratorStep<T>>;
}
