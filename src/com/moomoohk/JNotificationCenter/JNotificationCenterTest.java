package com.moomoohk.JNotificationCenter;


public class JNotificationCenterTest
{
	public static boolean loaded = false;
	static
	{
		try
		{
			System.loadLibrary("JNotificationCenter");
			loaded = true;
		}
		catch (UnsatisfiedLinkError err)
		{
			throw new RuntimeException(err);
		}
	}

	public static void main(String[] args)
	{
		String title = "title";
		String message = "message";
		String subtitle = "subtitle";
		String sender = "com.apple.safari";
		JNotificationCenter.showNotification(title, message, subtitle, sender);

		System.exit(0);
	}
}
