package com.moomoohk.JNotificationCenter;

public enum OSXSoundEffect
{
	BASSOW, BLOW, BOTTLE, FROG, FUNK, GLASS, HERO, MORSE, PING, POP, PURR, SOSUMI, SUBMARINE, TINK, DEFAULT;

	private String displayName;

	private OSXSoundEffect()
	{
		if (super.toString() == "DEFAULT")
			this.displayName = "default";
		else
			this.displayName = Character.toUpperCase(super.toString().charAt(0)) + super.toString().substring(1).toLowerCase();
	}

	@Override
	public String toString()
	{
		return this.displayName;
	}
}
