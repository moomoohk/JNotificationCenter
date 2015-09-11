package com.moomoohk.JNotificationCenter.notifications;

import com.moomoohk.JNotificationCenter.OSXSoundEffect;

public class URLNotification extends Notification
{
	protected String url;

	public URLNotification(String title, String message, String subtitle, String url)
	{
		super(title, message, subtitle);
		this.url = url;
	}

	public URLNotification(String title, String message, String subtitle, String sender, OSXSoundEffect sound, String url)
	{
		super(title, message, subtitle, sender, sound);
		this.url = url;
	}

	@Override
	public void show()
	{
		show(this.title, this.message, this.subtitle, this.sender, this.sound.toString(), this.url);
	}

	private native void show(String title, String message, String subtitle, String sender, String sound, String url);
}
