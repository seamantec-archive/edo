package com.store
{
import com.layout.LayoutHandler;
import com.loggers.SystemLogger;

import components.SettingsWindow;

import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;

public class MenuHandler extends NativeMenu
	{
		private var socketDispatcher;
		private var application;
		private var nMenu:NativeMenu;
		public function MenuHandler(socketDispatcher, app)
		{
			this.socketDispatcher = socketDispatcher;
			this.application = app;
			this.addSubmenu(createFileMenu(), "File");
			this.addSubmenu(createSocketMenu(), "Socket");
			this.addSubmenu(createLayoutMenu(), "Layout");
		}
		
		//TODO Kirakni kulon osztalyba, ez meg csak egy copy/paste, refaktor kelhet
		//MENUS
		
		
		private function createFileMenu(menuType=""):NativeMenu{
			var temp;
			var menu = new NativeMenu();
			temp = menu.addItem(new NativeMenuItem("Settings"));
			temp.keyEquivalent = 's';
			temp.data = "setting";				
			menu.addItem(new NativeMenuItem("",true));//separator				
			temp = menu.addItem(new NativeMenuItem("Quit"));
			temp.keyEquivalent = 'q';
			temp.data = "quit";
			
			for (var item = 0; item < menu.items.length; item++){
				menu.items[item].addEventListener(Event.SELECT,itemSelected, false, 0, true);
			} 
			return menu;
		}
		private function createSocketMenu():NativeMenu{
			var temp;
			var menu = new NativeMenu();
			var connected = new NativeMenuItem("Connect")
			BindingUtils.bindProperty(connected, "enabled", Statuses.instance, "inverseSocketStatus");
			//connected.enabled = Statuses.instance.socketStatus ? false : true;
			temp = menu.addItem(connected);
			temp.data = "connect";				
			menu.addItem(new NativeMenuItem("",true));//separator
			var dconnected = new NativeMenuItem("Disconnect");
			BindingUtils.bindProperty(dconnected, "enabled", Statuses.instance, "socketStatus");
			temp = menu.addItem(dconnected);
			temp.data = "disconnect";
			
			for (var item = 0; item < menu.items.length; item++){
				menu.items[item].addEventListener(Event.SELECT,itemSelected, false, 0, true);
			} 
			return menu;
		}
		
		private function createLayoutMenu():NativeMenu{
			var temp;
			var menu = new NativeMenu();
			temp = menu.addItem(new NativeMenuItem("Import"));
			temp.data = "layout-import";				
			
			var edit = menu.addItem(new NativeMenuItem("Edit"));
			edit.data = "layout-edit";
			edit.keyEquivalent = "l";
			
			var editDone = menu.addItem(new NativeMenuItem("Edit done"));
			editDone.data = "layout-edit-done";
			editDone.keyEquivalent = "l";
			BindingUtils.bindProperty(editDone, "enabled", LayoutHandler.instance, "editMode");
			
			temp = menu.addItem(new NativeMenuItem("Save"));
			temp.data = "layout-save";				
			
			
			
			for (var item = 0; item < menu.items.length; item++){
				menu.items[item].addEventListener(Event.SELECT,itemSelected, false, 0, true);
			} 
			return menu;	
		}
		
		private function itemSelected(event):void{
			switch(event.target.data)
			{
				case "setting":
				{
					new SettingsWindow().open();
					break;
				}
				case "quit":
				{						
					application.close();
					break;
				}
					
				case "connect":
				{						
					socketDispatcher.connect();
					break;
				}
					
				case "disconnect":
				{	
					socketDispatcher.close();
					break;
				}
					
				case "layout-import":
				{	
					//LayoutHandler.instance.importLayout();
					break;
				}
					
				case "layout-edit":
				{	
					LayoutHandler.instance.editEnabled = true;
					break;
				}
					
				case "layout-edit-done":
				{	
					LayoutHandler.instance.editMode = false;
					break;
				}
					
				case "layout-save":
				{	
					//LayoutHandler.instance.saveLayout();
					break;
				}
					
					
			}
			var message = "Selected item: \"" + event.target.label + "\" in " + event.target.data + ".";
			SystemLogger.Debug(message);				
		}
	}
}