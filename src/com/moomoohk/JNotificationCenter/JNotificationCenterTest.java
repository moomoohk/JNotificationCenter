package com.moomoohk.JNotificationCenter;

import com.moomoohk.JNotificationCenter.notifications.URLNotification;

public class JNotificationCenterTest
{
	public static void main(String[] args)
	{
		JNotificationCenter.load();

		String title = "title";
		String message = "message";
		String subtitle = "subtitle";
		String sender = "com.google.chrome";
		OSXSoundEffect sound = OSXSoundEffect.FUNK;
		String url = "http://google.com";
		URLNotification n = new URLNotification(title, message, subtitle, sender, sound, url);
		n.show();
	}
}
