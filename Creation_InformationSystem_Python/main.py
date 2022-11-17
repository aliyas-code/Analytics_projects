from re import I
from PyQt5 import QtCore, QtGui, QtWidgets
from PyQt5.QtGui import *
import re
import psycopg2
import pandas as pd


class Ui_MainWindow(object):

  def __init__(self):
    self.updateTrigger = None
    self.cur = None
    self.conn = None
    # Для инициализации
    self.trigger = False
    # Для открытия
    self.trigger2 = False

  def setupUi(self, MainWindow):
    MainWindow.setObjectName("MainWindow")
    MainWindow.resize(890, 505)
    self.centralwidget = QtWidgets.QWidget(MainWindow)
    self.centralwidget.setObjectName("centralwidget")
    self.init = QtWidgets.QPushButton(self.centralwidget)
    self.init.setGeometry(QtCore.QRect(10, 20, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.init.setFont(font)
    self.init.setObjectName("init")

    self.open = QtWidgets.QPushButton(self.centralwidget)
    self.open.setGeometry(QtCore.QRect(10, 70, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.open.setFont(font)
    self.open.setObjectName("open")

    self.showStatus = QtWidgets.QPushButton(self.centralwidget)
    self.showStatus.setGeometry(QtCore.QRect(230, 20, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.showStatus.setFont(font)
    self.showStatus.setObjectName("showStatus")

    self.close = QtWidgets.QPushButton(self.centralwidget)
    self.close.setGeometry(QtCore.QRect(230, 70, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.close.setFont(font)
    self.close.setObjectName("close")

    self.trFun = QtWidgets.QPushButton(self.centralwidget)
    self.trFun.setGeometry(QtCore.QRect(364, 473, 71, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.trFun.setFont(font)
    self.trFun.setObjectName("trFun")

    self.insert = QtWidgets.QPushButton(self.centralwidget)
    self.insert.setGeometry(QtCore.QRect(10, 140, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.insert.setFont(font)
    self.insert.setObjectName("insert")

    self.dele = QtWidgets.QPushButton(self.centralwidget)
    self.dele.setGeometry(QtCore.QRect(10, 170, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.dele.setFont(font)
    self.dele.setObjectName("dele")

    self.show = QtWidgets.QPushButton(self.centralwidget)
    self.show.setGeometry(QtCore.QRect(10, 110, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.show.setFont(font)
    self.show.setObjectName("show")

    self.textEdit = QtWidgets.QTextEdit(self.centralwidget)
    self.textEdit.setGeometry(QtCore.QRect(10, 210, 421, 101))
    self.textEdit.setObjectName("textEdit")

    self.lineEdit = QtWidgets.QLineEdit(self.centralwidget)
    self.lineEdit.setGeometry(QtCore.QRect(230, 170, 201, 22))
    self.lineEdit.setObjectName("lineEdit")

    self.treeView = QtWidgets.QTreeView(self.centralwidget)
    self.treeView.setGeometry(QtCore.QRect(90, 320, 256, 180))
    self.treeView.setObjectName("treeView")

    self.prompt = QtWidgets.QPushButton(self.centralwidget)
    self.prompt.setGeometry(QtCore.QRect(230, 110, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.prompt.setFont(font)
    self.prompt.setObjectName("prompt")

    self.Upd = QtWidgets.QPushButton(self.centralwidget)
    self.Upd.setGeometry(QtCore.QRect(230, 140, 201, 31))
    font = QtGui.QFont()
    font.setBold(True)
    self.Upd.setFont(font)
    self.Upd.setObjectName("Upd")

    # создание окна для таблицы
    self.tableWidget = QtWidgets.QTableWidget(self.centralwidget)
    self.tableWidget.setGeometry(QtCore.QRect(440, 20, 441, 471))
    self.tableWidget.setObjectName("tableWidget")
    self.tableWidget.setColumnCount(0)
    self.tableWidget.setRowCount(0)
    MainWindow.setCentralWidget(self.centralwidget)
    MainWindow.setCentralWidget(self.centralwidget)

    self.init.clicked.connect(self.prIn)
    self.showStatus.clicked.connect(self.prSh)
    self.close.clicked.connect(self.prCl)
    self.open.clicked.connect(self.prOp)
    self.show.clicked.connect(self.prCom)
    self.dele.clicked.connect(self.prDele)
    self.insert.clicked.connect(self.prInsert)
    self.prompt.clicked.connect(self.showPrompt)
    self.Upd.clicked.connect(self.forUpdates)
    self.trFun.clicked.connect(self.trFF)

    self.retranslateUi(MainWindow)
    QtCore.QMetaObject.connectSlotsByName(MainWindow)

  def populateTree(self, children, parent):
    for child in children:
      if child == 'postgres':
        child_item = QtGui.QStandardItem(child)
        parent.appendRow(child_item)
      else:
        child_item = QtGui.QStandardItem(child)
        parent.appendRow(child_item)
        if isinstance(children, dict):
          self.populateTree(children[child], child_item)

  def onSelectionChanged(self, *args):
    try:
      if (self.trigger2):
        for sel in self.treeView.selectedIndexes():
          val = sel.data()
          table_name = []
          self.frame1 = []
          grid_layout = QtWidgets.QGridLayout()
          self.tableWidget.setColumnCount(4)  # Устанавливаем три колонки
          self.tableWidget.setRowCount(100)
          self.tableWidget.setHorizontalHeaderLabels(["Header 1", "Header 2", "Header 3", "Header 4"])

          # Устанавливаем всплывающие подсказки на заголовки
          self.tableWidget.horizontalHeaderItem(0).setToolTip("Column 1 ")
          self.tableWidget.horizontalHeaderItem(1).setToolTip("Column 2 ")
          self.tableWidget.horizontalHeaderItem(2).setToolTip("Column 3 ")
          self.tableWidget.clear()

          if (val == 'postgres') | (val == 'inf'):
            self.tableWidget.setItem(1, 1, QtWidgets.QTableWidgetItem(val))
            self.tableWidget.resizeColumnsToContents()
            grid_layout.addWidget(self.tableWidget, 0, 0)

          else:
            self.frame1.append(self.tableNameToDataframe(val))

            table_name.append(val)

            self.updateTrigger = True

            self.setTables(self.frame1, table_name)

            self.tableWidget.resizeColumnsToContents()

            grid_layout.addWidget(self.tableWidget, 0, 0)

    except:
      print('что то пошло не так')


  def trFF(self):
    try:
      self.tree_new = {}
      self.cur.execute("SELECT datname From pg_database WHERE datistemplate=false;")
      self.records = self.cur.fetchall()
      self.db_names = [elem[0] for elem in self.records]

      self.cur.execute(" select table_name from information_schema.tables where table_schema = 'public';")
      self.records = self.cur.fetchall()
      self.db_tables = [elem[0] for elem in self.records]

      self.tree_new[self.db_names[0]] = None
      self.tree_new['inf'] = self.db_tables

      self.model = QStandardItemModel()
      self.populateTree(self.tree_new, self.model.invisibleRootItem())
      self.model.setHorizontalHeaderLabels(['База данных'])
      self.treeView.setModel(self.model)
      self.treeView.expandAll()
      self.treeView.selectionModel().selectionChanged.connect(self.onSelectionChanged)
    except:
      self.textEdit.setText('Откройте соединение')




  def showPrompt(self):
    mes = '''Для удаления нужно ввести название таблицы номер id, по которому будем удалять (например, provider 4).\n
Для вставки нужно написать название таблицы; значения (например, provider; 12 'CoolName' 6)\n
Для изенения нужно открыть либо одну таблицу(из дерева), либо открыть все таблицы("Просмотр"). После измените те данные, которые вы хотите. Дальше нажмите Enter + "Обновить"'''
    self.textEdit.setText(mes)

  def prIn(self):
    userStr = str(self.lineEdit.text())
    a = userStr.split()
    self.conn = psycopg2.connect(dbname=f'inf', user=f'postgres', password=f'Liedf11', host=f'localhost')
    self.trigger = True
    mes = "Инициализация прошла успешно"
    self.textEdit.setText(mes)

  def prOp(self):
    if (self.trigger):
      self.cur = self.conn.cursor()
      self.conn.autocommit = True
      self.trigger2 = True
      mes = "Открыто соединение"
      self.textEdit.setText(mes)
    else:
      mes = "Не инициализирован"
      self.textEdit.setText(mes)

  def prCl(self):
    if (self.trigger):
      self.conn.close()
      self.trigger = False
      self.trigger2 = False
      mes = "Закрыто соединение"
      self.textEdit.setText(mes)
    else:
      mes = "Соединение еще не открыто!"
      self.textEdit.setText(mes)

  def prSh(self):
    self.textEdit.setText(str(self.conn))

  def prDele(self):
    try:
      if (self.trigger2):
        userStr = str(self.lineEdit.text())
        s = userStr.split()
        self.cur.execute(f"delete from {s[0]} where id={s[1]};")
    except:
      self.textEdit.setText('Посмотрите подсказку!')

  def prInsert(self):
    try:
      if (self.trigger2):
        userStr = str(self.lineEdit.text())
        str_n = re.split("; | ", userStr)
        st_n = f"insert into {str_n[0]} values({', '.join(str_n[1::])})"
        self.cur.execute(st_n)
        self.textEdit.setText('Вставка завершена успешно!')
    except:
      self.textEdit.setText('Посмотрите подсказку!')

  def prCom(self):
    if (self.trigger2):  # создаание таблицы
      self.updateTrigger = False
      self.cur = self.conn.cursor()

      self.cur.execute("select table_name from information_schema.tables where table_schema ='public';")

      self.tablesName = self.cur.fetchall()

      self.tablesName = [elem[0] for elem in self.tablesName]

      self.frame1 = []
      for i in range(0, len(self.tablesName)):
        self.frame1.append(self.tableNameToDataframe(self.tablesName[i]))


      grid_layout = QtWidgets.QGridLayout()

      self.tableWidget.setColumnCount(5)  # Устанавливаем три колонки
      self.tableWidget.setRowCount(100)
      self.tableWidget.setHorizontalHeaderLabels(["Header 1", "Header 2", "Header 3", "Header 4"])

      # Устанавливаем всплывающие подсказки на заголовки
      self.tableWidget.horizontalHeaderItem(0).setToolTip("Column 1 ")
      self.tableWidget.horizontalHeaderItem(1).setToolTip("Column 2 ")
      self.tableWidget.horizontalHeaderItem(2).setToolTip("Column 3 ")
      self.tableWidget.clear()

      self.setTables(self.frame1, self.tablesName)

      self.tableWidget.resizeColumnsToContents()

      grid_layout.addWidget(self.tableWidget, 0, 0)  # Добавляем таблицу в сетку

    else:
      mes = "Соединение еще не открыто!"
      self.textEdit.setText(mes)


  def retranslateUi(self, MainWindow):
    _translate = QtCore.QCoreApplication.translate
    MainWindow.setWindowTitle(_translate("MainWindow", "Информационные системы - 2"))
    self.init.setText(_translate("MainWindow", "Инициализация соединения"))
    self.open.setText(_translate("MainWindow", "Открыть соединение"))
    self.showStatus.setText(_translate("MainWindow", "Показать состояние соединения"))
    self.close.setText(_translate("MainWindow", "Закрыть соединение"))
    self.insert.setText(_translate("MainWindow", "Вставить"))
    self.dele.setText(_translate("MainWindow", "Удалить"))
    self.show.setText(_translate("MainWindow", "Просмотр"))
    self.prompt.setText(_translate("MainWindow", "Подсказка"))
    self.Upd.setText(_translate("MainWindow", "Обновить"))
    self.trFun.setText(_translate("MainWindow", "Дерево"))

  def tableNameToDataframe(self, name):
    self.indexes = []
    self.date = []

    try:
      self.cur.execute(f"select * from {name};")
      self.records = self.cur.fetchall()
    except:
      print("Вы не соединились с базой данных")

    for i in range(0, len(self.records), 1):
      self.indexes.append(self.records[i][0])
      self.date.append(self.records[i])

    self.cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{name}' order by ordinal_position")
    self.records = self.cur.fetchall()

    self.columns = [elem[0] for elem in self.records]

    self.frame = pd.DataFrame(self.date, columns=self.columns)

    return self.frame


  def setTables(self, frame, table_names):
    self.y2 = 1
    # sup1 = 0
    # if len(table_names) == 1:
    #   sup1 = 1

    for i in range(0, len(table_names)):
      self.tableWidget.setItem(self.y2, 0, QtWidgets.QTableWidgetItem(str(table_names[i])))
      self.y2 += 1
      self.x1 = 0

      for xf in frame[i]:
        self.tableWidget.setItem(self.y2, self.x1, QtWidgets.QTableWidgetItem(str(xf)))
        for yf in range(0, len(frame[i][xf])):
          self.tableWidget.setItem(self.y2+1+yf, self.x1, QtWidgets.QTableWidgetItem(str(frame[i][xf][yf])))
        self.x1 += 1
      self.y2 += len(frame[i]) + 2
      self.xe = self.x1
      self.ye = self.y2


  def updateForOneTable(self):
    self.name = self.tableWidget.item(1, 0).text()
    xs = 2
    ys = 0

    self.cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{self.name}' order by ordinal_position")
    self.records = self.cur.fetchall()
    self.columns = [elem[0] for elem in self.records]

    print(self.columns)

    self.cur.execute(f"select * from {self.name};")
    records = self.cur.fetchall()


    for row in records:
      row_index = 0
      xs += 1
      for column in self.columns:
        yy = self.tableWidget.item(xs, ys).text()
        if (yy != row[row_index]):
          self.cur.execute(f"update {self.name} set {column}='{yy}' where id = {row[0]};")
        ys += 1
      row_index += 1
      ys = 0
    self.textEdit.setText("Выпонено!")

  def forUpdates(self):
    try:
      if self.updateTrigger == True:
        self.updateForOneTable()
      else:
        self.updateForALLTable()
    except:
      self.textEdit.setText("Откройте сначала таблицы")

  def updateForALLTable(self):

    self.cur.execute(f"select table_name from information_schema.tables where table_schema = 'public';")
    self.records = self.cur.fetchall()
    self.tables = [elem[0] for elem in self.records]

    xs = 2
    ys = 0

    for table in self.tables:
      self.cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table}' order by ordinal_position")
      self.records = self.cur.fetchall()
      self.columns = [elem[0] for elem in self.records]

      print(self.columns)

      self.cur.execute(f"select * from {table};")
      records = self.cur.fetchall()

      for row in records:
        row_index = 0
        xs += 1
        for column in self.columns:
          yy = self.tableWidget.item(xs, ys).text()
          if (yy != row[row_index]):
            self.cur.execute(f"update {table} set {column}='{yy}' where id = {row[0]};")
          ys += 1
        row_index += 1
        ys = 0
      xs += 3
      self.textEdit.setText("Выпонено!")


if __name__ == "__main__":
  import sys

  app = QtWidgets.QApplication(sys.argv)
  MainWindow = QtWidgets.QMainWindow()
  ui = Ui_MainWindow()
  ui.setupUi(MainWindow)
  MainWindow.show()
  sys.exit(app.exec_())
