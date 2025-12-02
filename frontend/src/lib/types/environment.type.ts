export type EnvironmentStatus = 'online' | 'offline' | 'error';

export type Environment = {
	id: string;
	name: string;
	apiUrl: string;
	status: EnvironmentStatus;
	enabled: boolean;
	lastSeen?: string;
	tags?: string[];
};

export interface CreateEnvironmentDTO {
	apiUrl: string;
	name: string;
	bootstrapToken?: string;
	tags?: string[];
}

export interface UpdateEnvironmentDTO {
	apiUrl?: string;
	name?: string;
	enabled?: boolean;
	bootstrapToken?: string;
	tags?: string[];
}
