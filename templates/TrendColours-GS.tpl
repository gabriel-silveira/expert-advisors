<chart>
id=132443259898994293
symbol=WINV20
description=IBOVESPA MINI
period_type=0
period_size=1
digits=0
tick_size=5.000000
position_time=1599758400
scale_fix=0
scale_fixed_min=98900.000000
scale_fixed_max=99865.000000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=1
fore=0
grid=0
volume=0
scroll=1
shift=0
shift_size=20.257235
fixed_pos=0.000000
ticker=1
ohlc=0
one_click=0
one_click_btn=1
bidline=1
askline=0
lastline=1
days=1
descriptions=0
tradelines=1
tradehistory=1
window_left=0
window_top=0
window_right=1916
window_bottom=491
window_type=1
floating=0
floating_left=0
floating_top=0
floating_right=0
floating_bottom=0
floating_type=1
floating_toolbar=1
floating_tbstate=
background_color=0
foreground_color=4737096
barup_color=65280
bardown_color=65280
bullcandle_color=0
bearcandle_color=16777215
chartline_color=65280
volumes_color=3329330
grid_color=1579032
bidline_color=10061943
askline_color=255
lastline_color=49152
stops_color=255
windows_total=1

<window>
height=126.972111
objects=13

<indicator>
name=Main
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\iMovment-Dmitry.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=Open;High;Low;Close
draw=17
style=0
width=1
arrow=251
color=255,7423,14591,22015,29183,36351,43775,50943,58111,65535,16711680,14818332,12990520,11162965,9269617,7441805,5614250,3720902,1893090,65535
</graph>
<inputs>
Movment=500
UpColor=16711680
UpBackColor=65535
DnColor=255
DnBackColor=65535
Auto5Digits=true
</inputs>
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=15570276
</graph>
period=34
method=0
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=16711935
</graph>
period=9
method=1
</indicator>
<object>
type=32
name=autotrade #350168847 sell 50 WINV20 at 98775
hidden=1
color=1918177
selectable=0
date1=1599841689
value1=98775.000000
</object>

<object>
type=31
name=autotrade #350175116 buy 50 WINV20 at 98675
hidden=1
descr=[tp 98675]
color=11296515
selectable=0
date1=1599842027
value1=98675.000000
</object>

<object>
type=32
name=autotrade #350180131 sell 10 WINV20 at 98525
hidden=1
color=1918177
selectable=0
date1=1599842276
value1=98525.000000
</object>

<object>
type=31
name=autotrade #350183113 buy 10 WINV20 at 98475
hidden=1
descr=[tp 98475]
color=11296515
selectable=0
date1=1599842343
value1=98475.000000
</object>

<object>
type=32
name=autotrade #350186270 sell 25 WINV20 at 98455
hidden=1
color=1918177
selectable=0
date1=1599842381
value1=98455.000000
</object>

<object>
type=31
name=autotrade #350186664 buy 25 WINV20 at 98405
hidden=1
descr=[tp 98405]
color=11296515
selectable=0
date1=1599842394
value1=98405.000000
</object>

<object>
type=32
name=autotrade #350196441 sell 10 WINV20 at 98365
hidden=1
color=1918177
selectable=0
date1=1599842782
value1=98365.000000
</object>

<object>
type=31
name=autotrade #350196929 buy 10 WINV20 at 98315
hidden=1
descr=[tp 98315]
color=11296515
selectable=0
date1=1599842797
value1=98315.000000
</object>

<object>
type=31
name=autotrade #350701038 buy 10 WINV20 at 99660
hidden=1
color=11296515
selectable=0
date1=1600090131
value1=99660.000000
</object>

<object>
type=2
name=autotrade #350168847 -> #350175116 WINV20
hidden=1
descr=98775 -> 98675
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1599841689
date2=1599842027
value1=98775.000000
value2=98675.000000
</object>

<object>
type=2
name=autotrade #350180131 -> #350183113 WINV20
hidden=1
descr=98525 -> 98475
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1599842276
date2=1599842343
value1=98525.000000
value2=98475.000000
</object>

<object>
type=2
name=autotrade #350186270 -> #350186664 WINV20
hidden=1
descr=98455 -> 98405
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1599842381
date2=1599842394
value1=98455.000000
value2=98405.000000
</object>

<object>
type=2
name=autotrade #350196441 -> #350196929 WINV20
hidden=1
descr=98365 -> 98315
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1599842782
date2=1599842797
value1=98365.000000
value2=98315.000000
</object>

</window>
</chart>