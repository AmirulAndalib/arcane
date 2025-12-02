package dto

type CreateEnvironmentDto struct {
	ApiUrl         string   `json:"apiUrl" binding:"required,url"`
	Name           *string  `json:"name,omitempty"`
	Enabled        *bool    `json:"enabled,omitempty"`
	AccessToken    *string  `json:"accessToken,omitempty"`
	BootstrapToken *string  `json:"bootstrapToken,omitempty"`
	Tags           []string `json:"tags,omitempty"`
}

type UpdateEnvironmentDto struct {
	ApiUrl         *string  `json:"apiUrl,omitempty" binding:"omitempty,url"`
	Name           *string  `json:"name,omitempty"`
	Enabled        *bool    `json:"enabled,omitempty"`
	AccessToken    *string  `json:"accessToken,omitempty"`
	BootstrapToken *string  `json:"bootstrapToken,omitempty"`
	Tags           []string `json:"tags,omitempty"`
}

type TestConnectionDto struct {
	Status  string  `json:"status"`
	Message *string `json:"message,omitempty"`
}

type EnvironmentDto struct {
	ID       string   `json:"id"`
	Name     string   `json:"name,omitempty"`
	ApiUrl   string   `json:"apiUrl"`
	Status   string   `json:"status"`
	Enabled  bool     `json:"enabled"`
	Tags     []string `json:"tags,omitempty"`
	LastSeen *string  `json:"lastSeen,omitempty"`
}

type CreateEnvironmentFilterDto struct {
	Name         string   `json:"name" binding:"required"`
	IsDefault    bool     `json:"isDefault"`
	SelectedTags []string `json:"selectedTags"`
	ExcludedTags []string `json:"excludedTags"`
	TagMode      string   `json:"tagMode"`
	StatusFilter string   `json:"statusFilter"`
	GroupBy      string   `json:"groupBy"`
}

type UpdateEnvironmentFilterDto struct {
	Name         *string  `json:"name,omitempty"`
	IsDefault    *bool    `json:"isDefault,omitempty"`
	SelectedTags []string `json:"selectedTags,omitempty"`
	ExcludedTags []string `json:"excludedTags,omitempty"`
	TagMode      *string  `json:"tagMode,omitempty"`
	StatusFilter *string  `json:"statusFilter,omitempty"`
	GroupBy      *string  `json:"groupBy,omitempty"`
}

type EnvironmentFilterDto struct {
	ID           string   `json:"id"`
	UserID       string   `json:"userId"`
	Name         string   `json:"name"`
	IsDefault    bool     `json:"isDefault"`
	SelectedTags []string `json:"selectedTags"`
	ExcludedTags []string `json:"excludedTags"`
	TagMode      string   `json:"tagMode"`
	StatusFilter string   `json:"statusFilter"`
	GroupBy      string   `json:"groupBy"`
	CreatedAt    string   `json:"createdAt,omitempty"`
	UpdatedAt    string   `json:"updatedAt,omitempty"`
}
