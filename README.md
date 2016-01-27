什么是Fanvas？
------------------------------------------

Fanvas是一个把swf转为html5 canvas动画的系统，由两部分组成：Actionscript实现的解析器、js运行库。

Flash做动画是最成熟最高效的方式，但由于终端基本不支持Flash播放，这给终端的动画制作带来了不少麻烦。

Fanvas是Flash和Canvas的完美结合，可以把swf（包括矢量和位图）完美地转化为canvas动画，让美术妹子一次制作，到处运行。。。

嘿嘿~~~让美术妹子也搭上H5的快车。



Fanvas的技术难点？
------------------------------------------
1、兼容swf的各种格式，主要是各种矢量命令和多种多样的图片格式；

2、实现高效的html5运行库，自主实现了位图缓存、自动脏区识别、脏区重绘等技术。


Fanvas的优势？
------------------------------------------
能转化swf为H5动画的工具，除了Fanvas还有大名鼎鼎的google和adobe的产品——swiffy和flashcc。
对比之下，Fanvas有如下优势：

1、从swf文件直接转化为Html5动画（google的swiffy和adobe的flashcc都不支持，两个产品都需要通过fla源文件处理）；

2、精简编排的JSON数据，使swf转化后的js数据文件非常小，普遍比flashcc导出的要小20%到50%；

3、精简的运行库，混淆后只有35k，gzip后只有10k左右。而swiffy和flashcc的运行库混淆后都超过100K;

4、开源，可供使用者二次开发（请保留Fanvas字样或版权声明）。



如何使用？
------------------------------------------
只需要一键导入swf，转化完成后一键导出canvas动画js。

具体请参考bin目录的《使用说明》


源代码说明
------------------------------------------
exporter是as3.0实现的swf文件解析器，解析后输出json数据；

runtime是js运行库，用于解析json数据，转化为最终canvas动画。


DEMO
------------------------------------------
http://kenkozheng.github.io/fanvas/magicEmotion/demo1/

http://kenkozheng.github.io/fanvas/magicEmotion/demo2/

http://kenkozheng.github.io/fanvas/magicEmotion/demo3/

http://kenkozheng.github.io/fanvas/magicEmotion/demo4/
