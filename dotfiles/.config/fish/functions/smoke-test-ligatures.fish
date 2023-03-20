function smoke-test-ligatures
  echo "Normal"
  echo -e "\033[1mBold\033[22m"
  echo -e "\033[3mItalic\033[23m"
  echo -e "\033[3;1mBold Italic\033[0m"
  echo -e "\033[4mUnderline\033[24m"
  echo -e "== === !== >= <= =>"
  echo -e "契          勒 鈴 "
end
