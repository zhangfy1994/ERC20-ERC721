# 此项目主要用于`ERC20` 和 `ERC721` 源码学习。

## 项目目录

- `contracts` 目录下，`MyERC20.sol`、`MyERC721.sol` 是不借助任何库完全从零实现。`MyERC20_2.sol`、`MyERC721_2.sol` 是借助@openzeppelin/contracts 库快速实现。

- test 目录是测试文件

- scripts 目录是部署文件

## 主要技术

- solidity^0.8.0
- 使用 hardhat 开发环境
- chai、hardhat-ethers 测试
- 部署到 polygon
- 使用 pnpm 管理依赖

## ⚠️ 注意点

- node 版本要 `>=18`，是 hardhat 的测试插件要求
- 如果`import`导入提示`Source "@openzeppelin/contracts/token/ERC20/ERC20.sol" not found: File import callback not supported`，请参考本项目`.vscode`的配置

## 项目使用

- 安装依赖

```shell
npm install

pnpm install

yarn install
```

- 跑测试

```shell
npx hardhat test

// 或指定具体测试文件
npx hardhat test ./test/filename
```

- 部署

```shell
npx hardhat run scripts/deploy.ts

// 部署到测试环境
npx hardhat run scripts/deploy.ts --network mumbai
```
