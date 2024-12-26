# U Do

A macOS menubar app that rotates tasks from to-do list on menubar.

一款 macOS 菜单栏应用程序，可以在菜单栏上轮换待办事项列表中的任务。

## Features 功能

- **Menubar Display:** Tasks are shown directly on the macOS menubar.

  **菜单栏显示：** 任务直接显示在 macOS 菜单栏上。

- **Automatic Rotation:** Tasks rotate every 5 seconds (Default) for easy tracking.

  **自动轮换：** 任务每 5 秒（默认）轮换一次，方便跟踪。

  [![SPYgO.gif](https://s7.gifyu.com/images/SPYgO.gif)](https://gifyu.com/image/SPYgO)

- **Settings:** Set your own time interval, priority color, and priority emoji.

  **设置：** 可以设置自己的时间间隔、优先级颜色和优先级表情符号。

  ![SPYW4.png](https://s13.gifyu.com/images/SPYW4.png)

- **Task Management:** Add, delete, and set time interval between tasks. Double click on the completed task to delete it.

  **任务管理：** 添加、删除任务并设置任务之间的时间间隔。双击已完成的任务即可删除。

  ![SPYWg.png](https://s7.gifyu.com/images/SPYWg.png)

- **Task Priority:** Able to select normal or high priority for your task. High-priority tasks will have a emoji in front.

  **任务优先级：** 可以为任务选择普通或高优先级。高优先级任务会在前方加上表情符号。

  ![SPYWc.png](https://s7.gifyu.com/images/SPYWc.png)

## Requirements 要求

- macOS 13.6 and after<br>macOS 13.6 及以上版本

## Installation Guide 安装教程

1. Download from releases.<br>从 releases 下载。
2. Drag U Do to Applications Folder.<br>将 U Do 拖动到“应用程序”文件夹。
3. Done.<br>完成。

> [!NOTE]
> If you encounter the error: *application is damaged and cannot be opened*, follow these steps:<br>如果遇到错误：“*应用程序已损坏，无法打开*”，请按照以下步骤操作：

1. Open Terminal.<br>打开终端。
2. Run the following command:<br>运行以下命令：

   ```bash
   sudo spctl --master-disable
   ```

3. Open the app.<br>打开应用程序。
4. Run the following command:<br>运行以下命令：

   ```bash
   sudo spctl --master-enable
   ```

5. Done.<br>完成。

## Instructions 使用指南

1. Press the + button to add a new task.<br>按下 + 按钮添加新任务。
2. Long press a task to set its priority.<br>长按任务以设置优先级。
3. Double click a task to mark it as done or delete it.<br>双击任务以标记为完成或删除。
4. Press the power off button to quit the U Do app.<br>按下电源按钮退出 U Do 应用程序。

## Links 链接

[Download 下载](https://github.com/chriyocc/U-Do/releases/latest)

## Contributing 贡献

- Feel free to report any [issues](https://github.com/chriyocc/U-Do/issues).<br>遇到问题可以提交 [issues](https://github.com/chriyocc/U-Do/issues).
- [Pull requests](https://github.com/chriyocc/U-Do/pulls) are always welcome.<br>随时欢迎 [Pull requests](https://github.com/chriyocc/U-Do/pulls).