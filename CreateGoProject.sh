#!/bin/bash
# 需要修改为可执行文件 chmod +x CreateGoProject.sh
# 然后 sh CreateGoProject.sh

# 切换到国内镜像
go env -w GO111MODULE=on
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct

# 提示用户输入项目名称
read -p "请输入项目名称: " project_name

# 检查用户是否输入了项目名称
if [ -z "$project_name" ]; then
  echo "项目名称不能为空。"
  exit 1
fi

# 创建项目目录并进入
mkdir "$project_name" && cd "$project_name"

# 初始化项目
go mod init "$project_name"

# 创建main.go文件
echo 'package main

import (
	"fmt"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
}

func main() {
	http.HandleFunc("/hello", helloHandler)
	http.ListenAndServe(":8081", nil)
}'> main.go

# 输出访问地址
echo "\n你的项目已经启动，可以在浏览器中以下地址访问接口 http://localhost:8081/hello"

# 运行项目
go run main.go
