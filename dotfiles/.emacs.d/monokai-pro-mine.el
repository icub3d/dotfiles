(require 'monokai-pro-theme)

(defvar monokai-pro-mine-theme-colors
  '(;; Background and foreground colors
    :bg     "#403e41"
    :bg+1   "#3b3c35"
    :bg+2   "#57584f"
    :fg-4   "#6e7066"
    :fg-3   "#919288"
    :fg-2   "#abaca0"
    :fg-1   "#fdfff1"
    :fg     "#fefff8"

    ;; General colors
    :white  "#fcfcfa"
    :red    "#ff6188"
    :orange "#fc9867"
    :yellow "#ffd866" 
    :green  "#a9dc76"
    :blue   "#66d9ee"
    :purple "#ab9df2"
    :pink   "#ff6188"

    ;; Colors from the original Monokai colorschemes. Some of these are used
    ;; rarely as highlight colors. They should be avoided if possible.
    :orig-red     "#f92672"
    :orig-orange  "#fd971f"
    :orig-yellow  "#e6db74"
    :orig-green   "#a6e22e"
    :orig-cyan    "#a1efe4"
    :orig-blue    "#66d9ef"
    :orig-violet  "#ae81ff"
    :orig-magenta "#fd5ff0"))

(deftheme monokai-pro-mine)
(monokai-pro-theme-define 'monokai-pro-mine monokai-pro-mine-theme-colors)
(provide-theme 'monokai-pro-mine)

(provide 'monokai-pro-mine)
