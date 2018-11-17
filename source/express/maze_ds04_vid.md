---
title: DS04 Maze - Video
date: 2018-11-17 11:00:23
layout: false
---

<!DOCTYPE html>
<head>
    <meta charset="UTF-8">
    <title>DS04 Maze - Video</title>
</head>
<body>
<style type="text/css">
    .mainContainer {
        display: block;
        width: 100%;
        margin-left: auto;
        margin-right: auto;
    }

    @media screen and (min-width: 1080px) {
        .mainContainer {
            display: block;
            width: 1080px;
            margin-left: auto;
            margin-right: auto;
        }
    }

    .video-container {
        position: relative;
        margin-top: 8px;
    }

    .centeredVideo {
        display: block;
        width: 100%;
        height: 100%;
        margin-left: auto;
        margin-right: auto;
        margin-bottom: auto;
    }
</style>

<div class="mainContainer">
    <div class="video-container">
        <script src="https://cdn.jsdelivr.net/npm/flv.js@1.4.2/dist/flv.min.js"
                integrity="sha256-aknMo2XB4nUPm6ofBMmYR6mall94cEeG9Dmjlu1IGs0=" crossorigin="anonymous"></script>
        <video id="videoElement" class="centeredVideo" controls></video>
        <script>
            if (flvjs.isSupported()) {
                var videoElement = document.getElementById('videoElement');
                var flvPlayer = flvjs.createPlayer({
                    type: 'flv',
                    url: 'https://yygc.zzjnyyz.cn/asset_files/2018-mazegen.flv'
                });
                flvPlayer.attachMediaElement(videoElement);
                flvPlayer.load();
            }
        </script>
    </div>
</div>
</body>
</html>
