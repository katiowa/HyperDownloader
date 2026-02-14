@echo off
setlocal enabledelayedexpansion
title Hyper Media Processor ULTRA [yt-dlp + ffmpeg]
cd /d "%~dp0"

:: =========================================================
:: VERIFICACAO DE ENTRADA (ARQUIVO LOCAL OU DOWNLOAD)
:: =========================================================
if not "%~1"=="" (
    set "modo=local"
    set "arquivo_entrada=%~1"
    goto :analise_local
) else (
    set "modo=download"
    goto :inicio_download
)

:inicio_download
cls
echo =========================================================
echo          HYPER MEDIA DOWNLOADER ULTRA
echo =========================================================
echo  Cole o link (YouTube, Spotify, Instagram, Twitch, X...)
echo =========================================================
set /p "url=URL: "

:: Limpa aspas se o usuario colar com elas
set "url=!url:"=!"

:categoria
cls
echo =========================================================
echo  O QUE VOCE DESEJA OBTER?
echo =========================================================
echo  [1] VIDEO COMPLETO (Imagem + Som)
echo  [2] APENAS AUDIO (Musica/Podcast)
echo  [3] TRECHO DE VIDEO (Cortar inicio e fim)
echo  [4] ANIMACAO / LOOP (GIF, WebP - Sem som)
echo =========================================================
set /p "tipo=Escolha: "

if "%tipo%"=="1" goto config_video
if "%tipo%"=="2" goto config_audio
if "%tipo%"=="3" goto config_trecho
if "%tipo%"=="4" goto config_animacao
goto categoria

:: =========================================================
:: CONFIGURACAO DE VIDEO COMPLETO
:: =========================================================
:config_video
cls
echo =========================================================
echo  CONFIGURACAO DE VIDEO
echo =========================================================
echo.
echo  --- Formato do Container ---
echo  [1] MP4 (Universal - H.264/AAC)
echo  [2] MKV (Melhor qualidade bruta)
echo  [3] WEBM (Nativo do YouTube/VP9)
set /p "v_fmt=Escolha: "

if "%v_fmt%"=="1" (
    set "ext_video=mp4"
    set "codec_video=libx264"
    set "codec_audio=aac"
)
if "%v_fmt%"=="2" (
    set "ext_video=mkv"
    set "codec_video=copy"
    set "codec_audio=copy"
)
if "%v_fmt%"=="3" (
    set "ext_video=webm"
    set "codec_video=copy"
    set "codec_audio=copy"
)

echo.
echo  --- Qualidade de Video ---
echo  [0] ORIGINAL/BEST (Melhor disponivel - Sem conversao)
echo  [1] MAXIMA ABSOLUTA (8K/4K original com re-encode)
echo  [2] 8K (4320p 120fps) - GIGANTE
echo  [3] 4K (2160p 120fps)
echo  [4] 4K (2160p 60fps)
echo  [5] 2K (1440p 60fps)
echo  [6] Full HD (1080p 60fps)
echo  [7] HD (720p 60fps)
echo  [8] SD (480p 30fps)
echo  [9] Baixa (360p) - Economizar
set /p "qual_video=Escolha: "

set "modo_video="
if "%qual_video%"=="0" (
    set "formato_video=bestvideo*+bestaudio/best"
    set "modo_video=original"
)
if "%qual_video%"=="1" set "formato_video=bestvideo*+bestaudio/best"
if "%qual_video%"=="2" set "formato_video=bestvideo[height<=4320][fps<=120]+bestaudio/best[height<=4320]"
if "%qual_video%"=="3" set "formato_video=bestvideo[height<=2160][fps<=120]+bestaudio/best[height<=2160]"
if "%qual_video%"=="4" set "formato_video=bestvideo[height<=2160][fps<=60]+bestaudio/best[height<=2160]"
if "%qual_video%"=="5" set "formato_video=bestvideo[height<=1440][fps<=60]+bestaudio/best[height<=1440]"
if "%qual_video%"=="6" set "formato_video=bestvideo[height<=1080][fps<=60]+bestaudio/best[height<=1080]"
if "%qual_video%"=="7" set "formato_video=bestvideo[height<=720][fps<=60]+bestaudio/best[height<=720]"
if "%qual_video%"=="8" set "formato_video=bestvideo[height<=480][fps<=30]+bestaudio/best[height<=480]"
if "%qual_video%"=="9" set "formato_video=bestvideo[height<=360]+bestaudio/best[height<=360]"

echo.
echo  --- Qualidade de Audio ---
echo  [0] ORIGINAL/BEST (Sem conversao - Recomendado)
echo  [1] ABSURDA (VBR Maximo - Melhor compressao)
echo  [2] INSANAMENTE ALTA (640 kbps CBR)
echo  [3] MUITO ALTA (512 kbps)
echo  [4] MAXIMA (320 kbps)
echo  [5] Alta (256 kbps)
echo  [6] Media (192 kbps)
echo  [7] Economica (128 kbps)
set /p "qual_audio=Escolha: "

set "modo_audio_video="
set "bitrate_audio=320k"
if "%qual_audio%"=="0" set "modo_audio_video=original"
if "%qual_audio%"=="1" set "bitrate_audio=0" & set "use_vbr=true"
if "%qual_audio%"=="2" set "bitrate_audio=640k"
if "%qual_audio%"=="3" set "bitrate_audio=512k"
if "%qual_audio%"=="4" set "bitrate_audio=320k"
if "%qual_audio%"=="5" set "bitrate_audio=256k"
if "%qual_audio%"=="6" set "bitrate_audio=192k"
if "%qual_audio%"=="7" set "bitrate_audio=128k"

:: Playlist
echo.
echo  --- E uma Playlist? ---
set /p "eh_playlist=Baixar a playlist inteira? (y/n): "
if /i "%eh_playlist%"=="y" (
    set "flag_playlist=--yes-playlist"
    set "nome_saida=%%(playlist_index)s - %%(title)s.%%(ext)s"
) else (
    set "flag_playlist=--no-playlist"
    set "nome_saida=%%(title)s.%%(ext)s"
)

:: Cookies
echo.
echo  --- Precisa de LOGIN/COOKIES? ---
echo  (Para conteudos privados, membros, +18)
echo  [n] Nao
echo  [c] Chrome
echo  [f] Firefox
echo  [e] Edge
set /p "cookie_opt=Opcao: "

set "cookies_cmd="
if /i "!cookie_opt!"=="c" set "cookies_cmd=--cookies-from-browser chrome"
if /i "!cookie_opt!"=="f" set "cookies_cmd=--cookies-from-browser firefox"
if /i "!cookie_opt!"=="e" set "cookies_cmd=--cookies-from-browser edge"

echo.
echo  [!] Iniciando download de VIDEO (%ext_video%)...

:: Executa download baseado nas opcoes
if "%modo_video%"=="original" (
    if "%modo_audio_video%"=="original" (
        echo  [MODO SUPREMO - 100%% ORIGINAL - Sem conversao]
        yt-dlp %cookies_cmd% %flag_playlist% --merge-output-format %ext_video% -f "%formato_video%" -o "%nome_saida%" "!url!"
    ) else (
        echo  [MODO ORIGINAL VIDEO + Audio customizado]
        yt-dlp %cookies_cmd% %flag_playlist% --merge-output-format %ext_video% -f "%formato_video%" -o "%nome_saida%" "!url!"
    )
) else (
    if "%modo_audio_video%"=="original" (
        echo  [Video customizado + MODO ORIGINAL AUDIO]
        yt-dlp %cookies_cmd% %flag_playlist% --merge-output-format %ext_video% -f "%formato_video%" -o "%nome_saida%" "!url!"
    ) else (
        if "%v_fmt%"=="1" (
            yt-dlp %cookies_cmd% %flag_playlist% --merge-output-format %ext_video% -f "%formato_video%" --postprocessor-args "ffmpeg:-c:v %codec_video% -crf 18 -preset slow -c:a %codec_audio% -b:a %bitrate_audio%" -o "%nome_saida%" "!url!"
        ) else (
            yt-dlp %cookies_cmd% %flag_playlist% --merge-output-format %ext_video% -f "%formato_video%" -o "%nome_saida%" "!url!"
        )
    )
)
goto fim

:: =========================================================
:: CONFIGURACAO DE AUDIO
:: =========================================================
:config_audio
cls
echo =========================================================
echo  CONFIGURACAO DE AUDIO
echo =========================================================
echo.
echo  --- Formato de Audio ---
echo  [0] ORIGINAL/BEST (Sem conversao - Melhor do site)
echo  [1] MP3 (Universal - Compativel com tudo)
echo  [2] M4A (Qualidade Apple/AAC)
echo  [3] FLAC (Sem perda - Arquivo enorme)
echo  [4] OGG (Melhor compressao - Spotify/Jogos)
echo  [5] WAV (Sem compressao - Profissional)
set /p "a_fmt=Escolha: "

set "modo_audio="
set "formato_audio=mp3"
set "ext_final=mp3"

if "%a_fmt%"=="0" (
    set "modo_audio=original"
    set "ext_final=original"
) else (
    if "%a_fmt%"=="1" set "formato_audio=mp3" & set "ext_final=mp3"
    if "%a_fmt%"=="2" set "formato_audio=m4a" & set "ext_final=m4a"
    if "%a_fmt%"=="3" set "formato_audio=flac" & set "ext_final=flac"
    if "%a_fmt%"=="4" set "formato_audio=vorbis" & set "ext_final=ogg"
    if "%a_fmt%"=="5" set "formato_audio=wav" & set "ext_final=wav"
    
    echo.
    echo  --- Qualidade de Audio ---
    echo  [0] SUPREMA (VBR q0 - Maximo VBR)
    echo  [1] INSANAMENTE ALTA (640 kbps CBR)
    echo  [2] MUITO ALTA (512 kbps)
    echo  [3] MAXIMA (320 kbps)
    echo  [4] Alta (256 kbps)
    echo  [5] Media (192 kbps)
    echo  [6] Economica (128 kbps)
    echo  [7] Minima (96 kbps)
    set /p "qual_audio=Escolha: "
    
    set "quality_flag=0"
    set "bitrate_custom=320k"
    set "vbr_mode="
    
    if "!qual_audio!"=="0" set "quality_flag=0" & set "bitrate_custom=0" & set "vbr_mode=true"
    if "!qual_audio!"=="1" set "quality_flag=0" & set "bitrate_custom=640k"
    if "!qual_audio!"=="2" set "quality_flag=0" & set "bitrate_custom=512k"
    if "!qual_audio!"=="3" set "quality_flag=0" & set "bitrate_custom=320k"
    if "!qual_audio!"=="4" set "quality_flag=1" & set "bitrate_custom=256k"
    if "!qual_audio!"=="5" set "quality_flag=3" & set "bitrate_custom=192k"
    if "!qual_audio!"=="6" set "quality_flag=5" & set "bitrate_custom=128k"
    if "!qual_audio!"=="7" set "quality_flag=7" & set "bitrate_custom=96k"
)

echo.
echo  --- E uma Playlist? ---
set /p "eh_playlist=Baixar a playlist inteira? (y/n): "
if /i "%eh_playlist%"=="y" (
    set "flag_playlist=--yes-playlist"
    set "nome_saida=%%(playlist_index)s - %%(title)s.%%(ext)s"
) else (
    set "flag_playlist=--no-playlist"
    set "nome_saida=%%(title)s.%%(ext)s"
)

:: Cookies
echo.
echo  --- Precisa de LOGIN/COOKIES? ---
echo  [n] Nao
echo  [c] Chrome
echo  [f] Firefox
echo  [e] Edge
set /p "cookie_opt=Opcao: "

set "cookies_cmd="
if /i "!cookie_opt!"=="c" set "cookies_cmd=--cookies-from-browser chrome"
if /i "!cookie_opt!"=="f" set "cookies_cmd=--cookies-from-browser firefox"
if /i "!cookie_opt!"=="e" set "cookies_cmd=--cookies-from-browser edge"

echo.
echo  [!] Extraindo AUDIO (%ext_final%)...

if "%modo_audio%"=="original" (
    echo  [MODO ORIGINAL - Melhor qualidade disponivel no site]
    yt-dlp %cookies_cmd% %flag_playlist% -f "bestaudio/best" -o "%nome_saida%" "!url!"
) else (
    if "%vbr_mode%"=="true" (
        echo  [MODO VBR MAXIMO - Melhor compressao]
        yt-dlp %cookies_cmd% %flag_playlist% -x --audio-format %formato_audio% --audio-quality 0 --postprocessor-args "ffmpeg:-q:a 0" -o "%nome_saida%" "!url!"
    ) else (
        yt-dlp %cookies_cmd% %flag_playlist% -x --audio-format %formato_audio% --audio-quality %quality_flag% --postprocessor-args "ffmpeg:-b:a %bitrate_custom%" -o "%nome_saida%" "!url!"
    )
)
goto fim

:: =========================================================
:: CONFIGURACAO DE TRECHO DE VIDEO
:: =========================================================
:config_trecho
cls
echo =========================================================
echo  CONFIGURACAO DE TRECHO
echo =========================================================
echo.
echo  --- Definir Tempo ---
set /p "t_inicio=Inicio (ex: 00:01:20 ou 1:20): "
set /p "t_fim=Fim    (ex: 00:01:25 ou 1:25): "

if "%t_inicio%"=="" goto config_trecho
if "%t_fim%"=="" goto config_trecho

set "secao_cmd=--download-sections *%t_inicio%-%t_fim% --force-keyframes-at-cuts"

echo.
echo  --- Qualidade de Video ---
echo  [0] SUPREMA (100%% sem alteracao - Copy codec)
echo  [1] MAXIMA ABSOLUTA (Qualidade maxima com re-encode)
echo  [2] 8K (4320p 120fps) - ABSURDO
echo  [3] 4K (2160p 120fps)
echo  [4] 4K (2160p 60fps)
echo  [5] Full HD (1080p 60fps)
echo  [6] HD (720p 60fps)
echo  [7] SD (480p)
set /p "qual_trecho=Escolha: "

set "modo_trecho="
set "formato_trecho=bestvideo*+bestaudio/best"
set "filtros_video="

if "%qual_trecho%"=="0" (
    set "modo_trecho=supremo"
)
if "%qual_trecho%"=="1" (
    set "modo_trecho=maxima"
)
if "%qual_trecho%"=="2" (
    set "formato_trecho=bestvideo[height<=4320][fps<=120]+bestaudio/best"
    set "filtros_video=fps=120,scale=-2:4320"
)
if "%qual_trecho%"=="3" (
    set "formato_trecho=bestvideo[height<=2160][fps<=120]+bestaudio/best"
    set "filtros_video=fps=120,scale=-2:2160"
)
if "%qual_trecho%"=="4" (
    set "formato_trecho=bestvideo[height<=2160][fps<=60]+bestaudio/best"
    set "filtros_video=fps=60,scale=-2:2160"
)
if "%qual_trecho%"=="5" (
    set "formato_trecho=bestvideo[height<=1080][fps<=60]+bestaudio/best"
    set "filtros_video=fps=60,scale=-2:1080"
)
if "%qual_trecho%"=="6" (
    set "formato_trecho=bestvideo[height<=720][fps<=60]+bestaudio/best"
    set "filtros_video=fps=60,scale=-2:720"
)
if "%qual_trecho%"=="7" (
    set "formato_trecho=bestvideo[height<=480]+bestaudio/best"
    set "filtros_video=fps=30,scale=-2:480"
)

echo.
echo  --- Com Audio? ---
set /p "com_audio=Incluir audio? (y/n): "

:: Cookies
echo.
echo  --- Precisa de LOGIN/COOKIES? ---
echo  [n] Nao
echo  [c] Chrome
echo  [f] Firefox
echo  [e] Edge
set /p "cookie_opt=Opcao: "

set "cookies_cmd="
if /i "!cookie_opt!"=="c" set "cookies_cmd=--cookies-from-browser chrome"
if /i "!cookie_opt!"=="f" set "cookies_cmd=--cookies-from-browser firefox"
if /i "!cookie_opt!"=="e" set "cookies_cmd=--cookies-from-browser edge"

echo.
echo  [!] Cortando trecho de %t_inicio% ate %t_fim%...

if "%modo_trecho%"=="supremo" (
    echo  [MODO SUPREMO - 100%% ORIGINAL - Copy codec]
    if /i "%com_audio%"=="n" (
        yt-dlp %cookies_cmd% %secao_cmd% -f "%formato_trecho%" --merge-output-format mp4 --postprocessor-args "ffmpeg:-c:v copy -an" -o "%%(title)s_Trecho.%%(ext)s" "!url!"
    ) else (
        yt-dlp %cookies_cmd% %secao_cmd% -f "%formato_trecho%" --merge-output-format mp4 --postprocessor-args "ffmpeg:-c:v copy -c:a copy" -o "%%(title)s_Trecho.%%(ext)s" "!url!"
    )
) else if "%modo_trecho%"=="maxima" (
    echo  [MODO MAXIMA ABSOLUTA - Re-encode CRF 15]
    if /i "%com_audio%"=="n" (
        yt-dlp %cookies_cmd% %secao_cmd% -f "%formato_trecho%" --merge-output-format mp4 --postprocessor-args "ffmpeg:-c:v libx264 -crf 15 -preset slow -an" -o "%%(title)s_Trecho.%%(ext)s" "!url!"
    ) else (
        yt-dlp %cookies_cmd% %secao_cmd% -f "%formato_trecho%" --merge-output-format mp4 --postprocessor-args "ffmpeg:-c:v libx264 -crf 15 -preset slow -c:a aac -b:a 320k" -o "%%(title)s_Trecho.%%(ext)s" "!url!"
    )
) else (
    echo  [Com filtros customizados]
    if /i "%com_audio%"=="n" (
        yt-dlp %cookies_cmd% %secao_cmd% -f "%formato_trecho%" --merge-output-format mp4 --postprocessor-args "ffmpeg:-c:v libx264 -crf 18 -vf %filtros_video% -an" -o "%%(title)s_Trecho.%%(ext)s" "!url!"
    ) else (
        yt-dlp %cookies_cmd% %secao_cmd% -f "%formato_trecho%" --merge-output-format mp4 --postprocessor-args "ffmpeg:-c:v libx264 -crf 18 -vf %filtros_video% -c:a aac -b:a 192k" -o "%%(title)s_Trecho.%%(ext)s" "!url!"
    )
)
goto fim

:: =========================================================
:: CONFIGURACAO DE ANIMACAO (GIF/WEBP)
:: =========================================================
:config_animacao
cls
echo =========================================================
echo  CONFIGURACAO DE ANIMACAO
echo =========================================================
echo.
echo  --- Tipo de Arquivo ---
echo  [1] GIF (Classico - Arquivo maior, compativel)
echo  [2] WebP (Moderno - Leve, alta qualidade)
echo  [3] MP4 (Apenas o trecho, sem converter)
set /p "ani_fmt=Escolha: "

echo.
echo  --- Recorte de Tempo ---
echo  Deixe em branco para baixar o video todo
set /p "t_inicio=Inicio (ex: 00:01:20): "
set /p "t_fim=Fim    (ex: 00:01:25): "

set "secao_cmd="
if not "%t_inicio%"=="" (
    if not "%t_fim%"=="" (
        set "secao_cmd=--download-sections *%t_inicio%-%t_fim% --force-keyframes-at-cuts"
    )
)

echo.
echo  --- Qualidade/FPS ---
echo  [0] SUPREMA (100%% ORIGINAL - Nenhum filtro) - GIGANTESCO
echo  [1] INSANA (Resolucao original + 120fps)
echo  [2] ABSURDA (4K + 120fps)
echo  [3] ULTRA (1080p + 120fps)
echo  [4] MUITO ALTA (1080p + 60fps)
echo  [5] Alta (720p + 60fps)
echo  [6] Media (720p + 30fps)
echo  [7] Compacta (480p + 24fps)
echo  [8] Discord/Zap (480p + 15fps) - Leve
set /p "qual=Escolha: "

set "modo_animacao="
set "filtros_vf="

if "%qual%"=="0" set "modo_animacao=supremo"
if "%qual%"=="1" set "filtros_vf=fps=120"
if "%qual%"=="2" set "filtros_vf=fps=120,scale=2160:-1:flags=lanczos"
if "%qual%"=="3" set "filtros_vf=fps=120,scale=1080:-1:flags=lanczos"
if "%qual%"=="4" set "filtros_vf=fps=60,scale=1080:-1:flags=lanczos"
if "%qual%"=="5" set "filtros_vf=fps=60,scale=720:-1:flags=lanczos"
if "%qual%"=="6" set "filtros_vf=fps=30,scale=720:-1:flags=lanczos"
if "%qual%"=="7" set "filtros_vf=fps=24,scale=480:-1:flags=lanczos"
if "%qual%"=="8" set "filtros_vf=fps=15,scale=480:-1:flags=lanczos"

:: Cookies
echo.
echo  --- Precisa de LOGIN/COOKIES? ---
echo  [n] Nao
echo  [c] Chrome
echo  [f] Firefox
echo  [e] Edge
set /p "cookie_opt=Opcao: "

set "cookies_cmd="
if /i "!cookie_opt!"=="c" set "cookies_cmd=--cookies-from-browser chrome"
if /i "!cookie_opt!"=="f" set "cookies_cmd=--cookies-from-browser firefox"
if /i "!cookie_opt!"=="e" set "cookies_cmd=--cookies-from-browser edge"

:: MP4 simples (sem conversao)
if "%ani_fmt%"=="3" (
    echo [!] Baixando trecho MP4...
    yt-dlp %cookies_cmd% %secao_cmd% -f "bestvideo*+bestaudio/best" --merge-output-format mp4 -o "%%(title)s_trecho.%%(ext)s" "!url!"
    goto fim
)

:: GIF com paleta
if "%ani_fmt%"=="1" (
    echo [!] Preparando GIF de alta qualidade...
    if "%modo_animacao%"=="supremo" (
        echo  [MODO SUPREMO - 100%% ORIGINAL]
        set "cmd_final=ffmpeg -y -i "{}" -vf "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -f gif "%%(title)s.gif" && del "{}""
    ) else (
        set "cmd_final=ffmpeg -y -i "{}" -vf "%filtros_vf%,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -f gif "%%(title)s.gif" && del "{}""
    )
)

:: WebP animado
if "%ani_fmt%"=="2" (
    echo [!] Preparando WebP Animado...
    if "%modo_animacao%"=="supremo" (
        echo  [MODO SUPREMO - 100%% ORIGINAL]
        set "cmd_final=ffmpeg -y -i "{}" -loop 0 -c:v libwebp -lossless 0 -q:v 75 "%%(title)s.webp" && del "{}""
    ) else (
        set "cmd_final=ffmpeg -y -i "{}" -vf "%filtros_vf%" -loop 0 -c:v libwebp -lossless 0 -q:v 75 "%%(title)s.webp" && del "{}""
    )
)

:: Executa download + conversao
yt-dlp %cookies_cmd% %secao_cmd% -f "bestvideo*+bestaudio/best" --merge-output-format mp4 --exec "!cmd_final!" -o "temp_%%(id)s.mp4" "!url!"
goto fim

:: =========================================================
:: ANALISE LOCAL (ARRASTAR E SOLTAR)
:: =========================================================
:analise_local
cls
echo =========================================================
echo           CONVERSOR DE ARQUIVO LOCAL
echo  Arquivo: "%~n1%~x1"
echo =========================================================
echo  [1] Converter para GIF
echo  [2] Converter para WebP (Sticker/Animado)
echo  [3] Extrair Audio (MP3)
echo  [4] Extrair Audio (FLAC - Sem perda)
echo  [5] Extrair Audio (OGG)
echo  [6] Recodificar Video (Reduzir tamanho)
echo =========================================================
set /p "loc_esc=Escolha: "

set "saida_loc=%~n1"

if "%loc_esc%"=="1" goto local_gif
if "%loc_esc%"=="2" goto local_webp
if "%loc_esc%"=="3" goto local_mp3
if "%loc_esc%"=="4" goto local_flac
if "%loc_esc%"=="5" goto local_ogg
if "%loc_esc%"=="6" goto local_recodificar
goto fim_local

:local_gif
echo.
echo [0] SUPREMA (100%% ORIGINAL - Sem filtros) - GIGANTE
echo [1] ABSURDA (4K, 120fps)
echo [2] INSANA (1080p, 120fps)
echo [3] ULTRA (1080p, 60fps)
echo [4] Alta (720p, 60fps)
echo [5] Media (480p, 30fps)
echo [6] Leve (480p, 15fps)
set /p "gif_qual=Qualidade do GIF: "

set "gif_filtros="
if "%gif_qual%"=="1" set "gif_filtros=fps=120,scale=2160:-1:flags=lanczos"
if "%gif_qual%"=="2" set "gif_filtros=fps=120,scale=1080:-1:flags=lanczos"
if "%gif_qual%"=="3" set "gif_filtros=fps=60,scale=1080:-1:flags=lanczos"
if "%gif_qual%"=="4" set "gif_filtros=fps=60,scale=720:-1:flags=lanczos"
if "%gif_qual%"=="5" set "gif_filtros=fps=30,scale=480:-1:flags=lanczos"
if "%gif_qual%"=="6" set "gif_filtros=fps=15,scale=480:-1:flags=lanczos"

echo Gerando Paleta e GIF...
if "%gif_qual%"=="0" (
    echo [MODO SUPREMO - 100%% ORIGINAL]
    ffmpeg -v error -i "%arquivo_entrada%" -vf "split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -y "%saida_loc%.gif"
) else (
    ffmpeg -v error -i "%arquivo_entrada%" -vf "%gif_filtros%,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -y "%saida_loc%.gif"
)
goto fim_local

:local_webp
echo.
echo [0] SUPREMA (100%% ORIGINAL - Sem filtros)
echo [1] ABSURDA (4K, 120fps)
echo [2] ULTRA (1080p, 60fps)
echo [3] Alta (720p, 60fps)
echo [4] Media (720p, 30fps)
echo [5] Leve (480p, 15fps)
set /p "webp_qual=Qualidade do WebP: "

set "webp_filtros="
if "%webp_qual%"=="1" set "webp_filtros=fps=120,scale=2160:-1:flags=lanczos"
if "%webp_qual%"=="2" set "webp_filtros=fps=60,scale=1080:-1:flags=lanczos"
if "%webp_qual%"=="3" set "webp_filtros=fps=60,scale=720:-1:flags=lanczos"
if "%webp_qual%"=="4" set "webp_filtros=fps=30,scale=720:-1:flags=lanczos"
if "%webp_qual%"=="5" set "webp_filtros=fps=15,scale=480:-1:flags=lanczos"

echo Gerando WebP...
if "%webp_qual%"=="0" (
    echo [MODO SUPREMO - 100%% ORIGINAL]
    ffmpeg -v error -i "%arquivo_entrada%" -loop 0 -c:v libwebp -preset default -q:v 75 -y "%saida_loc%.webp"
) else (
    ffmpeg -v error -i "%arquivo_entrada%" -vf "%webp_filtros%" -loop 0 -c:v libwebp -preset default -q:v 75 -y "%saida_loc%.webp"
)
goto fim_local

:local_mp3
echo.
echo [0] SUPREMA (VBR V0 - Maximo VBR)
echo [1] INSANAMENTE ALTA (640 kbps)
echo [2] MUITO ALTA (512 kbps)
echo [3] MAXIMA (320 kbps)
echo [4] Alta (256 kbps)
echo [5] Media (192 kbps)
set /p "mp3_qual=Qualidade do MP3: "

echo Extraindo MP3...
if "%mp3_qual%"=="0" (
    ffmpeg -v error -i "%arquivo_entrada%" -vn -q:a 0 -map 0:a -y "%saida_loc%.mp3"
) else (
    set "mp3_bitrate=320k"
    if "%mp3_qual%"=="1" set "mp3_bitrate=640k"
    if "%mp3_qual%"=="2" set "mp3_bitrate=512k"
    if "%mp3_qual%"=="3" set "mp3_bitrate=320k"
    if "%mp3_qual%"=="4" set "mp3_bitrate=256k"
    if "%mp3_qual%"=="5" set "mp3_bitrate=192k"
    ffmpeg -v error -i "%arquivo_entrada%" -vn -ab !mp3_bitrate! -map 0:a -y "%saida_loc%.mp3"
)
goto fim_local

:local_flac
echo Extraindo FLAC (Sem perda)...
ffmpeg -v error -i "%arquivo_entrada%" -vn -c:a flac -map 0:a -y "%saida_loc%.flac"
goto fim_local

:local_ogg
echo.
echo [0] MAXIMA (q10 - Melhor qualidade)
echo [1] Alta (q8)
echo [2] Media (q6)
echo [3] Economica (q4)
set /p "ogg_qual=Qualidade do OGG: "

set "ogg_q=10"
if "%ogg_qual%"=="1" set "ogg_q=8"
if "%ogg_qual%"=="2" set "ogg_q=6"
if "%ogg_qual%"=="3" set "ogg_q=4"

echo Extraindo OGG...
ffmpeg -v error -i "%arquivo_entrada%" -vn -c:a libvorbis -q:a %ogg_q% -map 0:a -y "%saida_loc%.ogg"
goto fim_local

:local_recodificar
echo Recodificando video (H.264, CRF 23)...
ffmpeg -v error -i "%arquivo_entrada%" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 192k -y "%saida_loc%_recodificado.mp4"
goto fim_local

:fim_local
echo.
echo =========================================================
echo  Conversao concluida!
echo =========================================================
pause
exit

:fim
echo.
echo =========================================================
echo  Processo concluido!
echo =========================================================
echo.
set /p "continuar=Deseja baixar outra midia? (y/n): "
if /i "%continuar%"=="y" goto inicio_download
exit
