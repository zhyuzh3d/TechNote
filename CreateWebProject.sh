#!/bin/bash
# 需要修改为可执行文件 chmod +x CreateWebProject.sh
# 然后 sh CreateWebProject.sh

#!/bin/bash

# 切换阿里云npm镜像
npm config set registry https://registry.npmmirror.com
npm config get registry
#!/bin/bash

# 提示用户输入项目名称
read -p "请输入项目名称: " project_name

# 检查用户是否输入了项目名称
if [ -z "$project_name" ]; then
  echo "项目名称不能为空。"
  exit 1
fi

# 创建项目目录并进入
mkdir "$project_name" && cd "$project_name"

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
    open: true, // 自动打开浏览器
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
echo 'const greet = () => {
    const hellostr = `Hello ES6!`
    const root = document.getElementById(`root`)
    root.innerHTML = `<h1>${hellostr}</h1><p>${new Date()}</p>`
    console.log(hellostr)
}
greet()' > src/index.js

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
npx json -I -f package.json -e 'this.scripts={"build":"webpack","dev":"webpack serve --open"}'

# 构建项目
npm run build

# 输出访问地址
echo "\n你的项目已经启动，可以在浏览器中访问 http://localhost:8080"

# 启动开发服务器
npm run dev
