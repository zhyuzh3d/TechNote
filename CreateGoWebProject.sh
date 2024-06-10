#!/bin/bash
# 需要修改为可执行文件 chmod +x CreateGoWebProject.sh
# 然后 sh CreateGoWebProject.sh

# Part1:创建golang项目

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
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"path/filepath"
)

func main() {
	// 创建路由器
	http.HandleFunc("/api", APIHandler)
	http.HandleFunc("/", ProxyHandler)

	// 启动服务器
	fmt.Println("Server is running at http://localhost:8081")
	if err := http.ListenAndServe(":8081", nil); err != nil {
		fmt.Printf("Error starting server: %v", err)
	}
}

// APIHandler 处理 /api 请求
func APIHandler(w http.ResponseWriter, r *http.Request) {
	jsonData, _ := json.Marshal(map[string]string{
		"message": "API response",
		"status":  "200",
	})
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonData)
}

// ProxyHandler 处理所有其他请求并代理到 localhost:8080
func ProxyHandler(w http.ResponseWriter, r *http.Request) {
	target := "http://localhost:8080"
	targetURL, _ := url.Parse(target)
	proxy := httputil.NewSingleHostReverseProxy(targetURL)
	proxy.ServeHTTP(w, r)
}

// StaticFileHandler 处理所有其他请求并提供静态文件服务,正式服务器使用
func StaticFileHandler(w http.ResponseWriter, r *http.Request) {
	staticDir := "./web/dist"
	filePath := filepath.Join(staticDir, r.URL.Path)
	// 检查文件是否存在
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		http.NotFound(w, r)
		return
	}
	// 提供静态文件服务
	http.ServeFile(w, r, filePath)
}'> main.go

# Part2:创建ES6-Web项目

# 创建项目目录并进入
mkdir "web" && cd "web"

# 初始化 npm 项目
npm init -y

# 安装开发所需的依赖
npm install --save-dev @babel/core @babel/cli @babel/preset-env webpack webpack-cli webpack-dev-server babel-loader html-webpack-plugin

# 创建 Babel 配置文件
echo '{
  "presets": ["@babel/preset-env"]
}' > .babelrc

# 创建 Webpack 配置文件
echo 'const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");

module.exports = {
  entry: "./src/index.js",
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "dist"),
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
        },
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/index.html",
    }),
  ],
  devServer: {
    static: {
      directory: path.join(__dirname, "dist"),
    },
    compress: true,
    port: 8080,
    open: false, // 自动打开浏览器
    client: {
      logging: "error", // 禁用客户端日志
    },
    devMiddleware: {
      stats: "errors-only", // 只输出错误信息
    },
  },
  mode: "development",
};' > webpack.config.js

# 创建项目结构
mkdir src
echo 'if (!window.isInitialized) {
    window.isInitialized = true
    const greet = async () => {
        const hellostr = `Hello ES6!`
        const root = document.getElementById(`root`)
        root.innerHTML = `<h1>${hellostr}</h1><p>${new Date()}</p>`
        console.log(hellostr)

        fetch(`/api`)
            .then(resp => resp.json())
            .then((resp) => {
                console.log(`/api:`, resp)
            })
    }
    greet()
}' > src/index.js

echo '<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ES6 Project</title>
</head>

<body>
    <div id="root"></div>
    <script src="bundle.js"></script>
</body>

</html>' > src/index.html

# 添加构建和启动脚本到 package.json
npx json -I -f package.json -e 'this.scripts={"build":"webpack","dev":"webpack serve"}'



# Part3:启动服务

# 查找并杀死占用8080端口的进程
for port in 8080 8081; do
  echo "Killing processes on port $port..."
  lsof -i tcp:$port | grep LISTEN | awk '{print $2}' | xargs kill -9
done



# 新窗口启动Web开放服务器
CUR_PATH=$(pwd)
osascript <<EOF
tell application "Terminal"
    do script "cd \"$CUR_PATH\" && npm run dev"
    activate
end tell
EOF

# 启动Golang服务器
echo "\n站点服务正在启动，请打开下面网址查看:http://localhost:8081"
cd .. && go run main.go

