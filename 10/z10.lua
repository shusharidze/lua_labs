lgi = require('lgi')
http = require('socket.http')
json = require('json')
gtk = lgi.require('Gtk', '3.0')
pixbuf = lgi.GdkPixbuf.Pixbuf

gtk.init()

bld = gtk.Builder()
bld:add_from_file('z10.glade')

ui = bld.objects


-- Вывод данных
function update()
	-- Ключ для подключения к API WeatherAPI
	local weatherapi_key = 'd7a7c17da50f4cfcb30231913231912'
							
	-- Ввод координат
	local location = ui.loc.text

	-- Получение данных о погоде
	local response = http.request('http://api.weatherapi.com/v1/current.json?key=' .. weatherapi_key .. '&q=' .. location)
	--print(response)

	-- Обработка ответа
	local json1 = json.decode(response)
	local temperature = tonumber(json1['current']['temp_c']) -- температура
	local humidity = json1['current']['humidity'] -- влажность
	local windspeed = tonumber(json1['current']['wind_kph']) -- скорость ветра
	local city = json1['location']['name'] -- город
	local weather = json1['current']['condition']['text'] -- погода в общем 
	local url_icon = tostring(json1['current']['condition']['icon']) -- URL иконки погоды
	

	-- Вывод на экран текстовых параметров
	ui.city.label = city
	ui.temp.label = temperature
	ui.hum.label = humidity
	ui.ws.label = windspeed
	ui.weather.label = weather
	
	
	-- Вывод на экран иконки погоды
	local body, code, headers, status = http.request('http:' .. url_icon)
	-- Проверяем, что ответ является успешным
	if code == 200 then
 	   local file = io.open("image.png", "wb") -- Создаем файл для сохранения изображения
	    file:write(body)                	   -- Сохраняем содержимое ответа в файл
	    file:close()
	    ui.image:set_from_file('image.png')  -- обновление картинки на экране
	else
	    print("Ошибка при загрузке изображения: " .. request.reason)
	end
  	
  	
  	-- Создание бэкапа с запросами
  	local backup_file = io.open('backup_file.txt', 'a')
  	backup_file:write(tostring(response .. '\n'))
	backup_file:close()
	
	-- Повторно открываем файл на чтение, чтобы считать данные бэкапа
	backup_file = io.open('backup_file.txt', 'r')
  	count_line = 1  -- Счетчик
  	ui.liststore1:clear() -- Очищаем лист, чтобы небыло наложения
  	
  	-- Цикл, в котором перебираем элементы бэкапа
  	while true do
  		local line =  backup_file:read('*l')
		if line == nil then break end 
		local decode_line = json.decode(line:sub(1, -1)) -- декодируем строку в джейсон
		iter = ui.liststore1:append()
		ui.liststore1[iter] = {[1] = count_line, [2] = tostring(decode_line['location']['name']), [3] = tostring(decode_line['location']['localtime'])}
		count_line = count_line + 1
	end
	backup_file:close()  -- Не забываем закрыть файл
end


-- Функция клика по кнопке
function ui.btn:on_clicked()
	update()
end

-- Функция закрытия окна
function ui.wnd:on_destroy()
	gtk.main_quit()
end

ui.wnd:show_all()
gtk.main()
