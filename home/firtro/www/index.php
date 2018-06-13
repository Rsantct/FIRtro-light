<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <!-- For iOS web apps -->
    <!-- http://developer.apple.com/library/ios/#documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html -->
    <!-- <meta name="viewport" content="width=device-width, initial-scale=1">  -->
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scaleable=no">
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="apple-mobile-web-app-title" content="FIRtro Mobile">

    <title>FIRtro Mobile</title>

    <!-- Temas de la pagina. Usar solo un tipo, o oficiales o a medida -->
    <!-- Temas a medida incluyen los standard a,b,c,d,e. -->
    <!-- http://jquerymobile.com/themeroller/ -->
    <link rel="stylesheet" href="css/themes/custom/myTheme.min.css" />
    <link rel="stylesheet" href="css/themes/default/jquery.mobile.structure-1.3.2.min.css" />

    <!-- Temas oficiales -->
    <!--<link rel="stylesheet" href="css/themes/default/jquery.mobile-1.2.0.min.css" /> -->

    <!-- Hojas de estilo principales -->
    <link href="css/jqm-docs.css" rel="stylesheet" type="text/css">
    <link href="css/main.css" rel="stylesheet" type="text/css">

    <!-- JQuery -->
    <script src="js/jquery-1.8.3.min.js"></script>
    <script src="js/jquery.mobile-1.3.2.min.js"></script>

    <!-- Jqplot -->
    <!--[if lt IE 9]><script language="javascript" type="text/javascript" src="excanvas.js"></script><![endif]-->
    <script language="javascript" type="text/javascript" src="jqplot/jquery.jqplot.min.js"></script>
    <script type="text/javascript" src="jqplot/plugins/jqplot.logAxisRenderer.min.js"></script>
    <script type="text/javascript" src="jqplot/plugins/jqplot.canvasOverlay.min.js"></script>
    <link rel="stylesheet" type="text/css" href="jqplot/jquery.jqplot.min.css" />

    <!-- Configuracion -->
    <script language="javascript" type="text/javascript">
        var $config=<?php echo json_encode(parse_ini_file("config/config.ini"))?>;
        var $config_ws=<?php echo json_encode(parse_ini_file("config/config.ini",True))?>;
        if ($config == false) alert('Error: Can not read configuration file');
    </script>

    <!-- Funciones -->
    <script src="js/functions.js"></script>
</head>

<body>


    <!-- ********************** -->
    <!-- ** Página principal VERSION LIGHT** -->
    <!-- ********************** -->

    <div data-role="page" class="type-interior" id="level_page">

        <div data-role="header" data-theme="d">
            <h1>FIRtro</h1>
            <a href="#info_page" data-icon="info" data-iconpos="notext" class="ui-btn-left">Info</a>
            <input name="reboot" value="REBOOT" type="submit" data-icon="alert" data-iconpos="notext" class="ui-btn-right"/>
        </div>

        <div class="content">
            
            <div data-role="content" id="level_display" class="display ui-corner-all">
                <div class="ui-grid-solo" id="level_display1">Waiting...</div>
                <div class="ui-grid-a">
                    <div class="ui-block-a"   id="level_display51"></div><!--input-->
                    <div class="ui-block-a"   id="level_display22"></div><!--loudness-->
                    <div class="ui-block-b"   id="level_display32" style="max-width:160px; min-width:130px"></div><!--syseq-->
                    <div class="ui-grid-solo" id="level_display6"></div><!--warnings-->
                </div>
            </div>
            
            <!-- aqui reutilizamos los botones de la pagina custom original -->
            <div class="ui-grid-b fitted">
              <div class="ui-block-a"><input id="custom_1" name="custom_1" type="submit" value="1" /></div>
              <div class="ui-block-b"><input id="custom_2" name="custom_2" type="submit" value="2" /></div>
              <div class="ui-block-c"><input id="custom_3" name="custom_3" type="submit" value="3" /></div>
              <div class="ui-block-a"><input id="custom_4" name="custom_4" type="submit" value="4" /></div>
              <div class="ui-block-b"><input id="custom_5" name="custom_5" type="submit" value="5" /></div>
              <div class="ui-block-c"><input id="custom_6" name="custom_6" type="submit" value="6" /></div>
              <div class="ui-block-a"><input id="custom_7" name="custom_7" type="submit" value="7" /></div>
              <div class="ui-block-b"><input id="custom_8" name="custom_8" type="submit" value="8" /></div>
              <div class="ui-block-c"><input id="custom_9" name="custom_9" type="submit" value="9" /></div>
            </div>

            <div class="ui-grid-b fitted">
              <div class="ui-block-a"><input id="loudness_toggle" name="loudness_toggle" type="submit" value="Loudness"/></div>
              <div class="ui-block-b"><input id="mute"            name="mute"            type="submit" value="mute"    /></div>
              <div class="ui-block-c"><input id="syseq_toggle"    name="syseq_toggle"    type="submit" value="sysEQ"   /></div>
            </div>

            <div class="ui-grid-a fitted">
              <div class="ui-block-a"><input id="level_down_3"  name="level_down_3" type="submit" value="VOL -"  data-icon="minus" /></div>
              <div class="ui-block-b"><input id="level_up_3"    name="level_up_3"   type="submit" value="VOL +"  data-icon="plus"  /></div>
            </div>

        </div>
        
    </div>

    <!-- ********************** -->
    <!-- ** Página INFO      ** -->
    <!-- ********************** -->

    <div data-role="page" class="type-interior" id="info_page">
        <!-- HEADER -->
        <div data-role="header" data-theme="d">
            <h1 name="tittle">FIRtro</h1>
            <a href="#level_page" data-icon="home" data-iconpos="notext" data-direction="reverse">Home</a>
        </div>
        <!--
            Letras grandes: Xvw (viewport percentage)
                            también 48px por si el browser no lo soporta
        -->
        <div style="font-size:48px; font-size:5.2vw;> <!--font-family:courier"-->
            <!--  ESTADO de FIRTRO
                   -----------------------------------------
                1  Vol: -32.0   Hr: 34.0     Bal: -2  Stereo
                2  Bass: -2     Treb: -3     SysEQ  DRC  PEQ
                3  P: preset_name            LOUD   xover:mp
                   -----------------------------------------
                4  I: input_name        ::pause::     44100
                   -----------------------------------------
            -->
            <div style="margin:10px; border-style:solid;">
                <!-- ui-grid-a/b/c/d son respectivamente 2/3/4/5 columnas -->
                <!-- LINEA 1-->
                <div class="ui-grid-c" style="margin:10px;font-weight:bold; width:100%">
                    <div class="ui-block-a" id="info_vol" style="text-align:left; width:30%">Vol:</div>
                    <div class="ui-block-b" id="info_hro" style="text-align:left; width:28%">Hr:</div>
                    <div class="ui-block-c" id="info_bal" style="text-align:left; width:18%">Bal:</div>
                    <div class="ui-block-d" id="info_ste" style="text-align:center; width:22%">(stereo)</div>
                </div>
                <!-- LINEA 2-->
                <div class="ui-grid-d" style="margin:10px;font-weight:bold; width:100%">
                    <div class="ui-block-a" id="info_bas" style="text-align:left; width:30%">Bass:</div>
                    <div class="ui-block-b" id="info_tre" style="text-align:left; width:28%">Tre:</div>
                    <div class="ui-block-c" id="info_seq" style="text-align:center; width:16%">(seq)</div>
                    <div class="ui-block-d" id="info_drc" style="text-align:center; width:13%">(drc)</div>
                    <div class="ui-block-e" id="info_peq" style="text-align:center; width:13%">(peq)</div>
                </div>
                <!-- LINEA 3-->
                <div class="ui-grid-b" style="margin:10px;font-weight:bold; width:100%">
                    <div class="ui-block-a" id="info_pre" style="text-align:left; width:62%">P:</div>
                    <div class="ui-block-b" id="info_lou" style="text-align:left; width:22%">(loud)</div>
                    <div class="ui-block-c" id="info_xov" style="text-align:center; width:16%">(xo)</div>
                </div>
            </div>
            <div style="margin:10px; border-style:solid;">
                <!-- LINEA 4-->
                <div class="ui-grid-b" style="margin:10px;font-weight:bold; width:100%; vertical-align=bottom">
                    <div class="ui-block-a" id="info_inp" style="text-align:center; width:50%">I:</div>
                    <div class="ui-block-b" id="info_sta" style="text-align:center; width:25%; font-size:36px; font-size:4vw;">_____</div>
                    <div class="ui-block-c" id="info_fs"  style="text-align:center; width:25%; font-size:36px; font-size:3vw;">(fs)</div>
                </div>
            </div>
            <!--   Metadatos del PLAYER en tres lineas enmarcadas -->
            <div style="margin:10px; font-weight:bold; text-align:center;">
                <div id="info_artist" style="border-style:solid; text-align:left;">Artist: --</div>
                <div id="info_album"  style="border-style:solid; text-align:left;">Album: --</div>
                <div id="info_title"  style="border-style:solid; text-align:left;">Title: --</div>
            </div>
        </div>

        <!-- FOOTER 
        Se incorpora una BOTONERA para funciones comunes: presets, inputs, playback_control, audio_control
        -->
        <div data-role="footer" class="footer-docs" data-theme="d">
            <div class="ui-grid-d">
                <!-- Copyright Firtro mobile-->
                <div class="ui-block-a" style="width:10%; padding-right:0px">
                    <p>&copy; FIRtro mobile</p>
                </div>
                <!-- Collapsible de PRESETS -->
                <div class="ui-block-b" style="width:16%; padding-right:5px">
                    <div data-role="collapsible" data-collapsed="True" data-mini="true">
                        <h3>Presets</h3>
                        <div id="info_presets_radiodiv">
                        <fieldset data-role="controlgroup" id="info_presets_select" class="center-controlgroup">
                        </fieldset>
                        </div>
                    </div>
                </div>
                <!-- Collapsible de INPUTS -->
                <div class="ui-block-c" style="width:18%; padding-left:5px">
                    <div data-role="collapsible" data-collapsed="True" data-mini="true">
                        <h3>Inputs</h3>
                        <div id="info_inputs_radiodiv">
                        <fieldset data-role="controlgroup" id="info_inputs_select" class="center-controlgroup">
                        </fieldset>
                        </div>
                    </div>
                </div>
                <!-- Botonera PLAYBACK CONTROL -->
                <div class="ui-block-d" style="width:22%;">
                    <div data-role="controlgroup" data-type="horizontal" class="footer_level" style="padding:0px">
                        <input name="info_prev"  type="submit" value="|<" />
                        <input name="info_rew"   type="submit" value="<<" />
                        <input name="info_pause" type="submit" value="||"/>
                        <input name="info_play"  type="submit" value=">" />
                        <input name="info_fwd"   type="submit" value=">>" />
                        <input name="info_next"  type="submit" value=">|" />
                    </div>
                </div>
                <!-- Botonera AUDIO CONTROL -->
                <div class="ui-block-e" style="width:34%">
                    <div data-role="controlgroup" data-type="horizontal" class="footer_level" style="padding-right:0px">
                        <input name="xover_toggle"    type="submit" value="XO" />
                        <input name="syseq_toggle"    type="submit" value="SQ" />
                        <input name="loudness_toggle" type="submit" value="Loud" />
                        <input name="mono"            type="submit" value="Mono" />
                        <input name="level_down"      type="submit" value="Vol" data-icon="minus" />
                        <input name="mute"            type="submit" value="Mute" />
                        <input name="level_up"        type="submit" value="Vol" data-icon="plus" data-iconpos="right" />
                    </div>
                </div>

            </div>
        </div><!-- /footer -->

    </div>

</body>
</html>
