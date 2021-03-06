package resource

import "time"

type Source struct {
	RepositoryURL      string `json:"repository_url"`
	ChartName          string `json:"chart"`
	Username           string `json:"username"`
	Password           string `json:"password"`
	SkipTLSValidation  bool   `json:"skip_tls_validation"`
	SortBy             string `json:"sort_by"`
	IncludePreReleases bool   `json:"include_pre_releases"`
}

type Version struct {
	Version string `json:"version"`
}

type MetadataField struct {
	Name  string `json:"name"`
	Value string `json:"value"`
}

type HelmChartInfo struct {
	Version     string    `yaml:"version"`
	AppVersion  string    `yaml:"appVersion"`
	APIVersion  string    `yaml:"apiVersion"`
	Created     time.Time `yaml:"created"`
	Description string    `yaml:"description"`
	Digest      string    `yaml:"digest"`
	URLs        []string  `yaml:"urls"`
}

type HelmChartRepository struct {
	Entries map[string][]HelmChartInfo `yaml:"entries"`
}
