function vj
  curl -sX POST -L --user icub3d:(cat ~/Documents/ssssh/jenkins.marsh.gg-api-token) -F "jenkinsfile=<$argv[1]" https://jenkins.marsh.gg/pipeline-model-converter/validate
end
