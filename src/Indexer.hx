import haxe.io.Path;
using StringTools;

typedef Record = {
    date: String,
    size: Int,
    path: String,
    fname: String,
    etag: String,
};

class Indexer
{
    static final googletagmanager_id = "GTM-M4JZKD";
    static function googletagmanager(id:String) {
        return "
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});final f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','" + id + "');</script>
<!-- End Google Tag Manager -->";
    }

    static function googletagmanager_noscript(id:String) {
        return '
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=' + id + '"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->';
    }

    public static function buildIndexPage(dirs:Array<String>, records:Array<Record>):String {
        final maxSizes = { date:25, size:15, fname:0 };
        for (r in records)
        {
            if (r.date.length > maxSizes.date)
                maxSizes.date = r.date.length;
            if (Std.string(r.size).length > maxSizes.size)
                maxSizes.size = Std.string(r.size).length;
            if (r.fname.length > maxSizes.fname)
                maxSizes.fname = r.fname.length;
        }
        records.sort(function(v1,v2) return Reflect.compare(v2.date,v1.date));
        final buf = new StringBuf();

        buf.add(
'<!DOCTYPE html>
<html>
<head>
    <title>Haxe git builds</title>
    ${googletagmanager(googletagmanager_id)}
</head>
<body>
    ${googletagmanager_noscript(googletagmanager_id)}
    <div id="listing">
    <pre>
');

        inline function data(date:String,size:String,key:String,path:String)
        {
            buf.add(date.rpad(' ',maxSizes.date));
            buf.add(size.rpad(' ',maxSizes.size));
            if (path != null && path != '')
                buf.add('<a href="$path">$key</a>\n');
            else
                buf.add('$key\n');
        }

        data('Last Modified', 'Size', 'Path','');
        for (i in 0...(maxSizes.date + maxSizes.size + maxSizes.fname + 5))
            buf.add('-');
        buf.add('\n\n');

        for (dir in dirs)
            data('','DIR',Path.withoutDirectory(Path.removeTrailingSlashes(dir)),dir);
        for (r in records)
            if (r.fname != 'index.html')
                data(r.date,Std.string(r.size),r.fname,r.fname);

        buf.add(
'
    </pre>
</div>
</body>
</html>
');

        return buf.toString();
    }
}
