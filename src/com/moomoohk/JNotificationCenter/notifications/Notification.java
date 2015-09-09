package com.moomoohk.JNotificationCenter.notifications;

import com.moomoohk.JNotificationCenter.OSXSoundEffect;

public abstract class Notification
{
	protected String title;
	protected String message;
	protected String subtitle;
	protected String sender;
	protected OSXSoundEffect sound;

	public Notification(String title, String message, String subtitle)
	{
		this(title, message, subtitle, "com.apple.Terminal", OSXSoundEffect.DEFAULT);
	}

	public Notification(String title, String message, String subtitle, String sender, OSXSoundEffect sound)
	{
		this.title = title;
		this.message = message;
		this.subtitle = subtitle;
		this.sender = sender;
		this.sound = sound;
	}

	public abstract void show();
}
