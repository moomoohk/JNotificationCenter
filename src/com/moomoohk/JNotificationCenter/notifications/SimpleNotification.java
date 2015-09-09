package com.moomoohk.JNotificationCenter.notifications;

import com.moomoohk.JNotificationCenter.OSXSoundEffect;

public class SimpleNotification extends Notification
{
	public SimpleNotification(String title, String message, String subtitle)
	{
		super(title, message, subtitle);
	}

	public SimpleNotification(String title, String message, String subtitle, String sender, OSXSoundEffect sound)
	{
		super(title, message, subtitle, sender, sound);
	}

	@Override
	public void show()
	{
		show(this.title, this.message, this.subtitle, this.sender, this.sound.toString());
	}

	private native void show(String title, String message, String subtitle, String sender, String sound);
}
